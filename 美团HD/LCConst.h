#ifdef DEBUG
#define LCLog(...) NSLog(__VA_ARGS__)
#else
#define LCLog(...)
#endif

#define LCColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define LCGlobalBg LCColor(230, 230, 230)