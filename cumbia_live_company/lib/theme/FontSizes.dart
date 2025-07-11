
class FontSizes {
  final bool isMobile;
  final double screenHeight;
  final double screenWidth;

  FontSizes(this.screenHeight, this.screenWidth)
      : isMobile = screenHeight >= screenWidth;

  double get title => isMobile ? screenWidth * 0.055 : screenHeight * 0.05;
  double get primary => isMobile ? screenWidth * 0.042 : screenHeight * 0.036;
  double get secondary => isMobile ? screenWidth * 0.036 : screenHeight * 0.026;
  double get content => isMobile ? screenWidth * 0.03 : screenHeight * 0.02;
  double get small => isMobile ? screenWidth * 0.026 : screenHeight * 0.016;
}
