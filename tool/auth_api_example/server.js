const crypto = require('crypto');
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const rateLimit = require('express-rate-limit');

const app = express();
app.use(express.json());

const JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || 'dev-access-secret';
const JWT_REFRESH_SECRET =
  process.env.JWT_REFRESH_SECRET || 'dev-refresh-secret';
const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL_DAYS = 30;
const MAGIC_LINK_TTL_MS = 10 * 60 * 1000;
const CHALLENGE_TTL_MS = 2 * 60 * 1000;
const CHALLENGE_MAX_ATTEMPTS = 3;

const usersByEmail = new Map();
const refreshTokensByHash = new Map();
const magicLinksByToken = new Map();
const challengesByEmail = new Map();

const authLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    code: 'RATE_LIMITED',
    message: 'Too many auth requests. Try again later.',
  },
});

const loginLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    code: 'TOO_MANY_LOGIN_ATTEMPTS',
    message: 'Too many login attempts. Please wait a few minutes.',
  },
});

app.use('/api/auth', authLimiter);
app.use('/api/auth/login', loginLimiter);
app.use('/api/auth/challenge/verify', loginLimiter);

function generateId() {
  return crypto.randomUUID();
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function nowPlusDays(days) {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
}

function issueAccessToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      displayName: user.displayName,
      preferredLanguage: user.preferredLanguage,
      skillLevel: user.skillLevel,
    },
    JWT_ACCESS_SECRET,
    { expiresIn: ACCESS_TOKEN_TTL }
  );
}

function issueRefreshToken(user) {
  const token = jwt.sign(
    { sub: user.id, type: 'refresh' },
    JWT_REFRESH_SECRET,
    { expiresIn: `${REFRESH_TOKEN_TTL_DAYS}d` }
  );
  refreshTokensByHash.set(hashToken(token), {
    userId: user.id,
    expiresAt: nowPlusDays(REFRESH_TOKEN_TTL_DAYS),
  });
  return token;
}

function rotateRefreshToken(previousRefreshToken, user) {
  refreshTokensByHash.delete(hashToken(previousRefreshToken));
  return issueRefreshToken(user);
}

function authResponse(user, previousRefreshToken) {
  const accessToken = issueAccessToken(user);
  const refreshToken = previousRefreshToken
    ? rotateRefreshToken(previousRefreshToken, user)
    : issueRefreshToken(user);

  return {
    user: {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      skillLevel: user.skillLevel,
      preferredLanguage: user.preferredLanguage,
      xp: user.xp,
    },
    tokens: {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: ACCESS_TOKEN_TTL,
    },
  };
}

function getUserByRefreshToken(refreshToken) {
  const stored = refreshTokensByHash.get(hashToken(refreshToken));
  if (!stored) return null;
  if (stored.expiresAt.getTime() <= Date.now()) {
    refreshTokensByHash.delete(hashToken(refreshToken));
    return null;
  }
  return [...usersByEmail.values()].find((user) => user.id === stored.userId) || null;
}

const challengeTemplates = [
  {
    language: 'Python',
    prompt: 'x = 2\nprint(x * 5)',
    question: 'What is the output?',
    answer: '10',
  },
  {
    language: 'JavaScript',
    prompt: "const name = 'JS';\nconsole.log(name.length);",
    question: 'What is the output?',
    answer: '2',
  },
  {
    language: 'SQL',
    prompt:
      'SELECT COUNT(*) FROM users WHERE email IS NOT NULL;\n-- rows: [A@email, NULL, B@email]',
    question: 'What number is returned?',
    answer: '2',
  },
];

function randomChallengeTemplate() {
  const index = Math.floor(Math.random() * challengeTemplates.length);
  return challengeTemplates[index];
}

app.post('/api/auth/register', async (req, res) => {
  const {
    email,
    password,
    displayName,
    skillLevel = 'beginner',
    preferredLanguage = 'python',
  } = req.body;

  if (!email || !password || !displayName) {
    return res.status(400).json({
      code: 'BAD_REQUEST',
      message: 'email, password, displayName are required',
    });
  }
  if (password.length < 6) {
    return res.status(400).json({
      code: 'WEAK_PASSWORD',
      message: 'Password must be at least 6 chars',
    });
  }

  const normalizedEmail = email.toLowerCase();
  if (usersByEmail.has(normalizedEmail)) {
    return res
      .status(409)
      .json({ code: 'EMAIL_IN_USE', message: 'Account already exists' });
  }

  const user = {
    id: generateId(),
    email: normalizedEmail,
    displayName,
    passwordHash: await bcrypt.hash(password, 12),
    skillLevel,
    preferredLanguage,
    xp: 0,
    streak: 0,
    createdAt: new Date(),
  };
  usersByEmail.set(normalizedEmail, user);
  return res.status(201).json(authResponse(user));
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const user = usersByEmail.get((email || '').toLowerCase());
  if (!user) {
    return res
      .status(401)
      .json({ code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' });
  }

  const valid = await bcrypt.compare(password || '', user.passwordHash);
  if (!valid) {
    return res
      .status(401)
      .json({ code: 'INVALID_CREDENTIALS', message: 'Invalid email or password' });
  }

  return res.status(200).json(authResponse(user));
});

app.post('/api/auth/google', (req, res) => {
  const { idToken, email, displayName = 'Google User' } = req.body;
  if (!idToken || !email) {
    return res
      .status(400)
      .json({ code: 'BAD_REQUEST', message: 'idToken and email are required' });
  }

  const normalizedEmail = email.toLowerCase();
  let user = usersByEmail.get(normalizedEmail);
  if (!user) {
    user = {
      id: generateId(),
      email: normalizedEmail,
      displayName,
      passwordHash: null,
      skillLevel: 'beginner',
      preferredLanguage: 'python',
      xp: 0,
      streak: 0,
      createdAt: new Date(),
    };
    usersByEmail.set(normalizedEmail, user);
  }

  return res.status(200).json(authResponse(user));
});

app.post('/api/auth/magic-link/request', (req, res) => {
  const email = (req.body.email || '').toLowerCase();
  if (!email || !email.includes('@')) {
    return res
      .status(400)
      .json({ code: 'INVALID_EMAIL', message: 'Valid email is required' });
  }

  const token = crypto.randomBytes(32).toString('hex');
  magicLinksByToken.set(token, {
    email,
    expiresAt: new Date(Date.now() + MAGIC_LINK_TTL_MS),
  });

  return res.status(200).json({
    ok: true,
    message: 'Magic link sent',
    debugMagicLink: `https://your-app.example.com/auth/magic?token=${token}`,
  });
});

app.post('/api/auth/magic-link/verify', (req, res) => {
  const token = req.body.token;
  const record = magicLinksByToken.get(token);
  if (!record) {
    return res
      .status(400)
      .json({ code: 'INVALID_MAGIC_LINK', message: 'Magic link is invalid' });
  }
  if (record.expiresAt.getTime() <= Date.now()) {
    magicLinksByToken.delete(token);
    return res
      .status(400)
      .json({ code: 'EXPIRED_MAGIC_LINK', message: 'Magic link has expired' });
  }

  let user = usersByEmail.get(record.email);
  if (!user) {
    user = {
      id: generateId(),
      email: record.email,
      displayName: record.email.split('@')[0],
      passwordHash: null,
      skillLevel: 'beginner',
      preferredLanguage: 'python',
      xp: 0,
      streak: 0,
      createdAt: new Date(),
    };
    usersByEmail.set(record.email, user);
  }

  magicLinksByToken.delete(token);
  return res.status(200).json(authResponse(user));
});

app.post('/api/auth/challenge/start', (req, res) => {
  const email = (req.body.email || '').toLowerCase();
  if (!email || !email.includes('@')) {
    return res
      .status(400)
      .json({ code: 'INVALID_EMAIL', message: 'Valid email is required' });
  }

  const template = randomChallengeTemplate();
  challengesByEmail.set(email, {
    answer: template.answer.toLowerCase(),
    attempts: 0,
    expiresAt: new Date(Date.now() + CHALLENGE_TTL_MS),
  });

  return res.status(200).json({
    language: template.language,
    prompt: template.prompt,
    question: template.question,
    expiresInSeconds: CHALLENGE_TTL_MS / 1000,
    maxAttempts: CHALLENGE_MAX_ATTEMPTS,
  });
});

app.post('/api/auth/challenge/verify', async (req, res) => {
  const email = (req.body.email || '').toLowerCase();
  const answer = (req.body.answer || '').trim().toLowerCase();
  const password = req.body.password || '';
  const challenge = challengesByEmail.get(email);

  if (!challenge) {
    return res
      .status(400)
      .json({ code: 'CHALLENGE_NOT_FOUND', message: 'Start a challenge first' });
  }
  if (challenge.expiresAt.getTime() <= Date.now()) {
    challengesByEmail.delete(email);
    return res
      .status(400)
      .json({ code: 'CHALLENGE_EXPIRED', message: 'Challenge expired' });
  }

  challenge.attempts += 1;
  if (answer !== challenge.answer) {
    const attemptsLeft = CHALLENGE_MAX_ATTEMPTS - challenge.attempts;
    if (attemptsLeft <= 0) {
      challengesByEmail.delete(email);
      return res.status(429).json({
        code: 'CHALLENGE_ATTEMPTS_EXCEEDED',
        message: 'Challenge attempts exceeded. Start a new challenge.',
      });
    }
    return res.status(400).json({
      code: 'CHALLENGE_WRONG_ANSWER',
      message: `Wrong answer. Attempts left: ${attemptsLeft}`,
    });
  }

  const user = usersByEmail.get(email);
  if (!user || !user.passwordHash) {
    return res
      .status(401)
      .json({ code: 'INVALID_CREDENTIALS', message: 'Invalid email/password' });
  }
  const validPassword = await bcrypt.compare(password, user.passwordHash);
  if (!validPassword) {
    return res
      .status(401)
      .json({ code: 'INVALID_CREDENTIALS', message: 'Invalid email/password' });
  }

  challengesByEmail.delete(email);
  return res.status(200).json(authResponse(user));
});

app.post('/api/auth/refresh', (req, res) => {
  const refreshToken = req.body.refreshToken;
  if (!refreshToken) {
    return res
      .status(400)
      .json({ code: 'BAD_REQUEST', message: 'refreshToken is required' });
  }

  try {
    jwt.verify(refreshToken, JWT_REFRESH_SECRET);
  } catch {
    return res
      .status(401)
      .json({ code: 'INVALID_REFRESH_TOKEN', message: 'Refresh token is invalid' });
  }

  const user = getUserByRefreshToken(refreshToken);
  if (!user) {
    return res
      .status(401)
      .json({ code: 'EXPIRED_REFRESH_TOKEN', message: 'Refresh token is expired' });
  }

  return res.status(200).json(authResponse(user, refreshToken));
});

app.post('/api/auth/logout', (req, res) => {
  const refreshToken = req.body.refreshToken;
  if (refreshToken) {
    refreshTokensByHash.delete(hashToken(refreshToken));
  }
  return res.status(200).json({ ok: true });
});

app.listen(8080, () => {
  console.log('Auth example API listening on http://localhost:8080');
});
