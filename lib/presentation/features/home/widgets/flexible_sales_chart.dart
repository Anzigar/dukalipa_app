import 'package:flutter/material.dart';

class FlexibleSalesChart extends StatelessWidget {
  const FlexibleSalesChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          padding: const EdgeInsets.all(4),
          child: CustomPaint(
            painter: SalesChartPainter(),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      }
    );
  }
}

class SalesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // y-axis
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, height),
      axisPaint,
    );
    
    // x-axis
    canvas.drawLine(
      Offset(0, height),
      Offset(width, height),
      axisPaint,
    );
    
    // Current month data
    final currentMonthPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final currentPoints = [
      Offset(width * 0.1, height * 0.8),
      Offset(width * 0.25, height * 0.5),
      Offset(width * 0.4, height * 0.6),
      Offset(width * 0.55, height * 0.3),
      Offset(width * 0.7, height * 0.4),
      Offset(width * 0.85, height * 0.2),
    ];
    
    // Draw current month path
    final currentPath = Path();
    currentPath.moveTo(currentPoints[0].dx, currentPoints[0].dy);
    
    for (int i = 1; i < currentPoints.length; i++) {
      currentPath.lineTo(currentPoints[i].dx, currentPoints[i].dy);
    }
    
    canvas.drawPath(currentPath, currentMonthPaint);
    
    // Previous month data with dotted line
    final prevMonthPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final prevPoints = [
      Offset(width * 0.1, height * 0.9),
      Offset(width * 0.25, height * 0.7),
      Offset(width * 0.4, height * 0.8),
      Offset(width * 0.55, height * 0.5),
      Offset(width * 0.7, height * 0.6),
      Offset(width * 0.85, height * 0.4),
    ];
    
    // Draw points for previous month (dotted effect)
    for (int i = 0; i < prevPoints.length - 1; i++) {
      drawDashedLine(
        canvas, 
        prevPoints[i], 
        prevPoints[i + 1], 
        prevMonthPaint,
      );
    }
    
    // Draw data points
    for (var point in currentPoints) {
      canvas.drawCircle(
        point, 
        4, 
        Paint()..color = Colors.green,
      );
    }
    
    for (var point in prevPoints) {
      canvas.drawCircle(
        point, 
        3, 
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        point, 
        3, 
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }
  
  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5;
    const dashSpace = 3;
    
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final count = (dx.abs() + dy.abs()) / (dashWidth + dashSpace);
    
    final dX = dx / count;
    final dY = dy / count;
    
    var currentX = start.dx;
    var currentY = start.dy;
    
    // Draw dashed line
    bool draw = true;
    final Paint dashPaint = Paint()
      ..color = paint.color
      ..strokeWidth = paint.strokeWidth
      ..style = PaintingStyle.stroke;
      
    for (int i = 0; i < count.floor(); i++) {
      if (draw) {
        canvas.drawLine(
          Offset(currentX, currentY),
          Offset(currentX + dX, currentY + dY),
          dashPaint,
        );
      }
      
      currentX += dX;
      currentY += dY;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
