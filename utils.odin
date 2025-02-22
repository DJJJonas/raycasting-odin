package raycasting

import "vendor:raylib"

DrawArrow :: proc(startPos, endPos: [2]f32, color: raylib.Color) {
  using raylib
  dir := Vector2Normalize(endPos - startPos)
  ang: f32 = PI/5
  DrawLineEx(startPos, endPos, 2, color)
  DrawLineEx(endPos, (endPos - Vector2Rotate(dir, +ang) * 10), 2, color)
  DrawLineEx(endPos, (endPos - Vector2Rotate(dir, -ang) * 10), 2, color)
}

DrawMeasure :: proc(startPos, endPos: [2]f32, color: raylib.Color = raylib.GREEN) {
  using raylib
  thickness :f32= 2
  DrawLineEx(startPos, {startPos.x + 8, startPos.y}, thickness, color)
  DrawLineEx(startPos, endPos, thickness, color)
  DrawLineEx(endPos, {endPos.x + 8, endPos.y}, thickness, color)
}
