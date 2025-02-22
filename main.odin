package raycasting

import "core:fmt"
import "core:math"
import "vendor:raylib"

Width     :: 960
Height    :: Width / 2

SectionSize  :: Width / 2
SquareSize :: SectionSize / MapWidth

floor :: math.floor

main :: proc() {
  using raylib

  InitWindow(Width, Height, "Raycaster")
  SetTargetFPS(60)

  DisableCursor()

  rotationCurr: f32 = 0
  rotationAng: f32 = 0.1

  handPositionY: f32 = SectionSize + 10
  handShake: f32 = 0
  handShakeAnim: f32 = 0.12

  texture: [3]Texture
  texture[0] = LoadTexture("assets/brick-caramel.png")
  texture[1] = LoadTexture("assets/brick-gray.png")
  texture[2] = LoadTexture("assets/brick-stone.png")
  pistol := LoadTexture("assets/pistol.png")

  // Map editing variables
  selectedBlock := 0

  for !WindowShouldClose() {
    BeginDrawing()
    ClearBackground(BLACK)
    // Get mouse coordinate
    mouseX := GetMouseX()
    mouseY := GetMouseY()
    // Draw floor
    DrawRectangle(SectionSize, SectionSize / 2, SectionSize, SectionSize / 2, BEIGE)
    // Raycasting calculations
    for x in 0 ..< SectionSize {
      pixel := 2 * f32(x) / f32(SectionSize) - 1
      rayDir := Vector2 {
        Player.dir.x + Player.cam.x * pixel,
        Player.dir.y + Player.cam.y * pixel,
      }
      // Cast the ray and return the information
      ray := CastRay(
        Player.pos,
        rayDir,
        Map
      )
      // 3D Perspective drawing
      lineHeight := floor(SectionSize / ray.perpDistWall)
      drawStart: f32 = SectionSize / 2 - lineHeight / 2
      // texturing calculations
      texNum: int = Map[ray.mapY][ray.mapX] - 1
      tex := texture[texNum]
      // calculate value of wallX as [0-1]
      wallX: f32
      if ray.side == 0 do wallX = Player.pos.y + ray.perpDistWall * rayDir.y
      else             do wallX = Player.pos.x + ray.perpDistWall * rayDir.x
      wallX -= floor(wallX)
      // x coordinate on the texture
      texX := wallX * f32(tex.width)
      // Fix inverted textures
      if ray.side == 0 && rayDir.x < 0 do texX = f32(tex.width) - texX - 1
      if ray.side == 1 && rayDir.y > 0 do texX = f32(tex.width) - texX - 1 
      // Draw wall texture
      DrawTexturePro(
        texture[texNum],
        {
          texX,
          0,
          1,
          f32(tex.height)
        },
        { 
          f32(SectionSize + x),
          drawStart,
          1,
          lineHeight,
        },
        { 0, 0 },
        0,
        WHITE,
      )
    }
    // Draw pistol
    {
      scale: f32 = 1.8
      width := f32(pistol.width) * scale
      height := f32(pistol.height) * scale
      handShake += handShakeAnim
      y :f32= math.sin(handShake) * 5
      if handShake > PI * 2 do handShake = 0
      DrawTexturePro(
        pistol,
        { 0, 0, 128, 128 },
        { SectionSize * 2, handPositionY + y, width, height },
        { width, height },
        0,
        WHITE,
      )
    }
    // Map Editing drawing
    // Draw vertical lines
    for col: i32 = 0; col < SectionSize; col += SquareSize {
      DrawLine(col, 0, col, SectionSize - 1, DARKGRAY)
    }
    // Draw horizontal lines
    for row: i32 = 0; row < SectionSize; row += SquareSize {
      DrawLine(0, row, SectionSize - 1, row, DARKGRAY)
    }
    // Draw wall squares
    for row, y in Map {
      for square, x in row {
        if square > 0 {
          DrawTexturePro(
            texture[square - 1],
            { 0, 0, f32(texture[square - 1].width), f32(texture[square - 1].height) },
            { auto_cast x * auto_cast SquareSize, auto_cast y * auto_cast SquareSize, auto_cast SquareSize, auto_cast SquareSize },
            { 0, 0 },
            0,
            WHITE,
          )
        }
      }
    }

    Player.vel = Vector2Normalize(Player.vel) 
    Player.vel = Player.vel * Player.speed
    // Collision Detection
    vPotentialPosition := Player.pos + Player.vel
    vCurrentCell := Vector2 { floor(Player.pos.x), floor(Player.pos.y) }
    vAreaTL   := Vector2Clamp(vCurrentCell - 1, {0, 0}, {MapWidth, MapHeight} - 1)
    vAreaBR   := Vector2Clamp(vCurrentCell + 1, {0, 0}, {MapWidth, MapHeight} - 1)
    vRayToNearest: Vector2
    vCell := Vector2(0)
    for vCell.y = vAreaTL.y; vCell.y <= vAreaBR.y; vCell.y += 1 {
      for vCell.x = vAreaTL.x; vCell.x <= vAreaBR.x; vCell.x += 1 {
        if Map[int(vCell.y)][int(vCell.x)] > 0 {
          vNearestPoint := Vector2Clamp(Player.pos, vCell, vCell + 1)
          vRayToNearest = vNearestPoint - vPotentialPosition
          fOverlap: f32 = Player.radius - Vector2Length(vRayToNearest)
          if fOverlap > 0 {
            vPotentialPosition = vPotentialPosition - Vector2Normalize(vRayToNearest) * fOverlap
          }
        }
      }
    }
    Player.pos = vPotentialPosition

    if Player.vel.x == 0 && Player.vel.y == 0 {
      handShakeAnim = 0
      handShake = Lerp(handShake, 0, 0.1)
    }
    else do handShakeAnim = 0.12

    Player.vel = Vector2(0)
    // Draw player dir arrow
    DrawArrow(
      Player.pos * f32(SquareSize),
      (Player.pos + Player.dir * 1.4) * f32(SquareSize), 
      SKYBLUE,
    )
    // Draw Player
    DrawCircle(
      i32(Player.pos.x * (SectionSize / MapWidth)),
      i32(Player.pos.y * (SectionSize / MapHeight)),
      Player.radius * f32(SquareSize),
      RED,
    )
    /// Player movement
    if IsKeyDown(KeyboardKey.W) { Player.vel += Player.dir }
    if IsKeyDown(KeyboardKey.A) { Player.vel += Vector2Rotate(Player.dir, -PI / 2) }
    if IsKeyDown(KeyboardKey.S) { Player.vel += -Player.dir }
    if IsKeyDown(KeyboardKey.D) { Player.vel += Vector2Rotate(Player.dir, +PI / 2) }
    /* First person mode */
    if IsCursorHidden() {
      if IsKeyPressed(KeyboardKey.V) {
        // Go Map editing mode
        EnableCursor()
      }
      mouseDelta := GetMouseDelta()
      Player.dir = Vector2Rotate(Player.dir, mouseDelta.x * CAMERA_MOUSE_MOVE_SENSITIVITY)
      Player.cam = Vector2Rotate(Player.cam, mouseDelta.x * CAMERA_MOUSE_MOVE_SENSITIVITY)
    } else { 
      /* Map editing mode */
      if IsKeyPressed(KeyboardKey.V) {
        // Go First person mode
        DisableCursor() 
      }

      blockX := mouseX / SquareSize
      blockY := mouseY / SquareSize

      mouseInsideEditingSection := mouseY >= 0 && mouseY < SectionSize && mouseX >= 0 && mouseX < SectionSize
      mouseInsidePlayingSection := mouseY >= 0 && mouseY < SectionSize && mouseX >= SectionSize && mouseX < SectionSize * 2

      if mouseInsidePlayingSection {
      }

      if mouseInsideEditingSection {
        rotationCurr += rotationAng
        if rotationCurr > PI * 2 do rotationCurr = 0
        DrawRectanglePro(
          {
            SectionSize * 1.5,
            SectionSize * 0.5,
            102,
            102,
          },
          {51, 51},
          math.sin(rotationCurr) * 12,
          WHITE
        )
        DrawTexturePro(
          texture[selectedBlock],
          {
            0,
            0,
            f32(texture[selectedBlock].width),
            f32(texture[selectedBlock].height)
          },
          {
            SectionSize * 1.5,
            SectionSize * 0.5,
            100,
            100,
          },
          {50, 50},
          math.sin(rotationCurr) * 12,
          WHITE,
        )
        // Place blocks
        if IsMouseButtonDown(MouseButton.LEFT)  do Map[blockY][blockX] = selectedBlock + 1
        // Remove blocks
        if IsMouseButtonDown(MouseButton.RIGHT) do Map[blockY][blockX] = 0        
        // Select next color
        if GetMouseWheelMove() > 0 {
          selectedBlock -= 1
          if selectedBlock < 0 do selectedBlock = 0
        }
        // Select previous color
        if GetMouseWheelMove() < 0 {
          selectedBlock += 1
          if l := len(texture); selectedBlock >= l {
            selectedBlock = l - 1
          }
        }
      }
      // Print map
      if IsKeyPressed(KeyboardKey.P) {
        fmt.println(Map)
      }
    }
    // Manual Camera movement
    CameraSpeed :f32: 0.1
    // Rotate left
    if IsKeyDown(KeyboardKey.Q) do PlayerRotate(-CameraSpeed)
    // Rotate right
    if IsKeyDown(KeyboardKey.E) do PlayerRotate(+CameraSpeed)
    // Debug info
    DrawFPS(20, 20)

    EndDrawing()
  }

  CloseWindow()
}
