package raycasting

import "core:math"
import "vendor:raylib"

RayInfo :: struct {
  sideDist: raylib.Vector2,
  deltaDist: raylib.Vector2,
  perpDistWall: f32,
  mapX: int,
  mapY: int,
  stepX: int,
  stepY: int,
  side: int,
}

CastRay :: proc(pos, rayDir: raylib.Vector2, Map: [][]int) -> RayInfo {
  using raylib

  mapX := int(pos.x)
  mapY := int(pos.y)

  sideDist := Vector2(0)
  deltaDist := Vector2{
    (rayDir.x == 0) ? math.INF_F32 : math.abs(1 / rayDir.x),
    (rayDir.y == 0) ? math.INF_F32 : math.abs(1 / rayDir.y),
  }
  perpDistWall: f32

  stepX: int
  stepY: int

  hit := 0
  side: int

  if rayDir.x < 0 {
    stepX = -1
    sideDist.x = (pos.x - f32(mapX)) * deltaDist.x
  } else {
    stepX = 1
    sideDist.x = (f32(mapX) + 1.0 - pos.x) * deltaDist.x
  }
  if rayDir.y < 0 {
    stepY = -1
    sideDist.y = (pos.y - f32(mapY)) * deltaDist.y
  } else {
    stepY = 1
    sideDist.y = (f32(mapY) + 1.0 - pos.y) * deltaDist.y
  }
  // DDA calculation
  for hit == 0 {
    if sideDist.x < sideDist.y {
      sideDist.x += deltaDist.x
      mapX += stepX
      side = 0
    } else {
      sideDist.y += deltaDist.y
      mapY += stepY
      side = 1
    }
    if Map[mapY][mapX] > 0 do hit = 1
  }

  if side == 0 do perpDistWall = (sideDist.x - deltaDist.x)
  else         do perpDistWall = (sideDist.y - deltaDist.y)

  return {
    sideDist,
    deltaDist,
    perpDistWall,
    mapX,
    mapY,
    stepX,
    stepY,
    side,
  }
}
