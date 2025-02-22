package raycasting

import raylib "vendor:raylib"

Player : struct {
  pos   : raylib.Vector2,
  dir   : raylib.Vector2,
  cam   : raylib.Vector2,
  vel   : raylib.Vector2,
  radius: f32,
  speed : f32,
} = {
  pos = {11.5, 22.0},
  dir = {0, -1},
  cam = {.66, 0},
  vel = {0, 0},
  radius = 0.48,
  speed = 0.1,
}

PlayerRotate :: proc(angle: f32) {
  using raylib
  Player.dir = Vector2Rotate(Player.dir, angle)
  Player.cam = Vector2Rotate(Player.cam, angle)
}
