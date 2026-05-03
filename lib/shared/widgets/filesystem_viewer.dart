import 'package:flutter/material.dart';

/// Visual file manager for bash learning - shows current directory structure
/// Similar to Norton Commander with folder tree and current contents
class FileSystemViewer extends StatefulWidget {
  /// Current directory path
  final String currentDirectory;

  /// Folder/file structure - key: name, value: isDirectory
  final Map<String, bool> contents;

  /// All available directories for tree view
  final List<String> allDirectories;

  /// Called when user clicks folder to navigate there
  final Function(String path) onNavigate;

  const FileSystemViewer({
    Key? key,
    required this.currentDirectory,
    required this.contents,
    required this.allDirectories,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<FileSystemViewer> createState() => _FileSystemViewerState();
}

class _FileSystemViewerState extends State<FileSystemViewer> {
  late Set<String> _expandedFolders;

  @override
  void initState() {
    super.initState();
    _expandedFolders = {widget.currentDirectory};
  }

  @override
  void didUpdateWidget(FileSystemViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDirectory != widget.currentDirectory) {
      _expandedFolders.add(widget.currentDirectory);
    }
  }

  void _toggleFolder(String path) {
    setState(() {
      if (_expandedFolders.contains(path)) {
        _expandedFolders.remove(path);
      } else {
        _expandedFolders.add(path);
      }
    });
  }

  List<String> _getSubFolders(String parentPath) {
    return widget.allDirectories
        .where((dir) {
          if (dir == parentPath) return false;
          final parent = dir.substring(0, dir.lastIndexOf('/'));
          return parent == parentPath;
        })
        .toList()
      ..sort();
  }

  Widget _buildFolderTree(String path, {int indent = 0}) {
    final subFolders = _getSubFolders(path);
    final isExpanded = _expandedFolders.contains(path);
    final isCurrentDir = path == widget.currentDirectory;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (subFolders.isNotEmpty) {
              _toggleFolder(path);
            }
            widget.onNavigate(path);
          },
          child: Container(
            color: isCurrentDir ? Colors.blue.shade100 : Colors.transparent,
            padding: EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4 + indent * 12,
            ),
            child: Row(
              children: [
                if (subFolders.isNotEmpty)
                  SizedBox(
                    width: 20,
                    child: Text(
                      isExpanded ? '▼' : '▶',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                Text(
                  '📁 ${path.split('/').last.isEmpty ? 'home' : path.split('/').last}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrentDir ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentDir ? Colors.blue.shade900 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...subFolders.map((subPath) => _buildFolderTree(subPath, indent: indent + 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '📂 Folders',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Current: ${widget.currentDirectory.split('/').last.isEmpty ? '/' : widget.currentDirectory.split('/').last}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Folder tree
          Expanded(
            child: SingleChildScrollView(
              child: _buildFolderTree('/home/ubuntu'),
            ),
          ),
          // Current directory contents
          const Divider(height: 1),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '📄 Contents',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.contents.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: widget.contents.entries.map((entry) {
                    final name = entry.key;
                    final isDir = entry.value;
                    return GestureDetector(
                      onTap: isDir ? () => widget.onNavigate('${widget.currentDirectory}/$name') : null,
                      child: Container(
                        color: isDir && (widget.contents[name] ?? false) ? Colors.amber.shade50 : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              isDir ? '📁' : '📄',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDir ? Colors.blue : Colors.black87,
                                  decoration: isDir ? TextDecoration.underline : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
