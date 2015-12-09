PVector RGB2Lab(color c) {
  float R = gamma(red(c) / 255.0f);
  float G = gamma(green(c) / 255.0f);
  float B = gamma(blue(c) / 255.0f);
  float X = 0.412453 * R + 0.357580 * G + 0.180423 * B;
  float Y = 0.212671 * R + 0.715160 * G + 0.072169 * B;
  float Z = 0.019334*R + 0.119193 * G + 0.950227 * B;
  X = X * 100.0f / 95.047;
  Y = Y * 100.0f / 100.0;
  Z = Z * 100.0f / 108.883;
  float FX = X > 0.008856f ? pow(X, 1.0f / 3.0f) : (7.787f * X + 0.137931f);
  float FY = Y > 0.008856f ? pow(Y, 1.0f / 3.0f) : (7.787f * Y + 0.137931f);
  float FZ = Z > 0.008856f ? pow(Z, 1.0f / 3.0f) : (7.787f * Z + 0.137931f);
  return new PVector(Y > 0.008856f ? (116.0f * FY - 16.0f) : (903.3f * Y),
                     500.f * (FX - FY),
                     200.f * (FY - FZ));
}

float gamma(float x) {
  return x > 0.04045 ? pow((x + 0.055f) / 1.055f, 2.4f) : x / 12.92f;
}

color Lab2RGB(PVector lab) {
  float Y = (lab.x + 16.0f) / 116.0f;
  float X = lab.y / 500 + Y;
  float Z = Y - lab.z / 200;

  Y = pow(Y, 3.0f) > 0.008856 ? pow(Y, 3.0f) : (Y - 16.0f / 116.0f ) / 7.787f;
  X = pow(X, 3.0f) > 0.008856 ? pow(X, 3.0f) : (X - 16.0f / 116.0f ) / 7.787f;
  Z = pow(Z, 3.0f) > 0.008856 ? pow(Z, 3.0f) : (Z - 16.0f / 116.0f ) / 7.787f;

  X = 0.95047f * X;
  Y = 1.0f * Y;
  Z = 1.08883f * Z;
  
  float R = X *  3.2406f + Y * -1.5372 + Z * -0.4986;
  float G = X * -0.9689f + Y *  1.8758 + Z *  0.0415;
  float B = X *  0.0557f + Y * -0.2040 + Z *  1.0570;

  R = R > 0.0031308 ? 1.055 * pow(R, (1 / 2.4)) - 0.055f : 12.92 * R;
  G = G > 0.0031308 ? 1.055 * pow(G, (1 / 2.4)) - 0.055f : 12.92 * G;
  B = B > 0.0031308 ? 1.055 * pow(B, (1 / 2.4)) - 0.055f : 12.92 * B;  
  
  //println(R * 255.0f, G * 255.0f, B * 255.0f);
  
  return color(R * 255.0f, G * 255.0f, B * 255.0f);
}