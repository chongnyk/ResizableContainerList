import 'package:flutter/material.dart';

void main() => runApp(ResizableContainersApp());

class ResizableContainersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resizable Containers',
      home: ResizableContainersPage(),
    );
  }
}

class ResizableContainersPage extends StatefulWidget {
  @override
  _ResizableContainersPageState createState() =>
      _ResizableContainersPageState();
}

class _ResizableContainersPageState extends State<ResizableContainersPage> {
  // List to store heights of each container
  List<double> _heights = [];

  // Minimum height for each container
  final double _minHeight = 100.0;

  // Heights of the drag handles
  final double _handleHeight = 10.0;

  // Number of containers
  final int _numContainers = 3;

  // Flag to check if heights are initialized
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resizable Containers'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Total available height
          double totalHeight = constraints.maxHeight;

          // Calculate total height occupied by handles
          double totalHandlesHeight = (_numContainers - 1) * _handleHeight;

          // Calculate available height for containers
          double availableHeight = totalHeight - totalHandlesHeight;

          // Initialize heights if not done yet
          if (!_isInitialized) {
            double initialHeight = availableHeight / _numContainers;
            _heights = List<double>.filled(_numContainers, initialHeight);
            _isInitialized = true;
          }

          return Column(
            children: _buildResizableContainers(availableHeight),
          );
        },
      ),
    );
  }

  List<Widget> _buildResizableContainers(double availableHeight) {
    List<Widget> widgets = [];

    for (int i = 0; i < _numContainers; i++) {
      // Add the container with explicit height using AnimatedContainer for smooth transitions
      widgets.add(
        AnimatedContainer(
          duration: Duration(microseconds: 100),
          height: _heights[i],
          color: _getColor(i),
          child: Center(
            child: Text(
              'Container ${i + 1}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );

      // Add a drag handle between containers, except after the last one
      if (i < _numContainers - 1) {
        widgets.add(
          _ResizableHandle(
            handleHeight: _handleHeight,
            onDragUpdate: (details) {
              _onDrag(details, i);
            },
          ),
        );
      }
    }

    return widgets;
  }

  // Function to handle drag updates
  void _onDrag(DragUpdateDetails details, int index) {
    setState(() {
      double delta = details.delta.dy;

      // Calculate the new heights
      double newHeightAbove = _heights[index] + delta;
      double newHeightBelow = _heights[index + 1] - delta;

      // Apply minimum height constraints
      if (newHeightAbove < _minHeight) {
        newHeightBelow -= (_minHeight - newHeightAbove);
        newHeightAbove = _minHeight;
      } else if (newHeightBelow < _minHeight) {
        newHeightAbove -= (_minHeight - newHeightBelow);
        newHeightBelow = _minHeight;
      }

      // Ensure heights do not go below minimum
      if (newHeightAbove < _minHeight) {
        newHeightAbove = _minHeight;
      }
      if (newHeightBelow < _minHeight) {
        newHeightBelow = _minHeight;
      }

      _heights[index] = newHeightAbove;
      _heights[index + 1] = newHeightBelow;
    });
  }

  // Function to assign colors to containers
  Color _getColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red
    ];
    return colors[index % colors.length];
  }
}

class _ResizableHandle extends StatefulWidget {
  final double handleHeight;
  final Function(DragUpdateDetails) onDragUpdate;

  _ResizableHandle({required this.handleHeight, required this.onDragUpdate});

  @override
  __ResizableHandleState createState() => __ResizableHandleState();
}

class __ResizableHandleState extends State<_ResizableHandle> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onVerticalDragUpdate: widget.onDragUpdate,
      onVerticalDragEnd: (_) {
        setState(() {
          _isDragging = false;
        });
      },
      child: Container(
        height: widget.handleHeight,
        color: _isDragging ? Colors.grey[500] : Colors.grey[300],
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
