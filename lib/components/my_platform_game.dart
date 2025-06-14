import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'starting_platform.dart';
import 'player.dart';
import 'platform.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import 'wingman_obstacle.dart';
import 'item.dart';

class MyPlatformGame extends FlameGame with DragCallbacks {
  late Player player;
  late StartingPlatform startPlatform;
  final List<Platform> platforms = [];
  final List<WingmanObstacle> obstacles = [];
  final Random random = Random();
  Vector2? dragStart;

  late World world;

  double lastPlatformY = 0;
  final double verticalGap = 300;

  double? prevPlayerY;
  double cameraMinY = 0;
  double cameraSpeed = 150;

  double screenWidth = 360; // 기본값, onGameResize에서 갱신
  double screenHeight = 640; // 기본값, onGameResize에서 갱신

  double minPlayerY = double.infinity; // 플레이어가 올라간 최고점

  bool isGeneratingPlatform = false; // 발판 생성 중 여부

  final int platformPoolSize = 100;

  late double platformWidth; // 추가

  int score = 0; // 점수 추가

  final double obstacleGap = 200; // 장애물 간격

  int nextObstacleScore = 70;
  int nextItemScore = 100; // 다음 아이템 생성 점수

  bool isGameOver = false;

  final List<Item> jetpackItems = [];
  final List<Item> wingsItems = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world = World();
    add(world);
    camera.world = world;

    // 시작 발판 생성
    startPlatform = await StartingPlatform.load(
      game: this,
      imagePath: 'assets/spritesheet_jumper.png',
      xmlPath: 'assets/spritesheet_jumper.xml',
      spriteName: 'ground_grass.png',
    );
    world.add(startPlatform);

    // 시작 발판의 top을 lastPlatformY로!
    lastPlatformY = startPlatform.position.y - startPlatform.size.y;

    // 플레이어는 시작 발판의 top 바로 위에 생성
    player = await Player.load(
      game: this,
      imagePath: 'assets/spritesheet_jumper.png',
      xmlPath: 'assets/spritesheet_jumper.xml',
      spriteName: 'bunny2_stand.png',
      position: Vector2(
        startPlatform.size.x / 2,
        lastPlatformY - 250, // 더 위에서 시작
      ),
      scale: 0.4,
    );
    world.add(player);

    // ground_grass.png의 원본 크기 얻기
    final xmlString = await rootBundle.loadString('assets/spritesheet_jumper.xml');
    final document = XmlDocument.parse(xmlString);
    final element = document.findAllElements('SubTexture')
        .firstWhere((e) => e.getAttribute('name') == 'ground_grass.png');

    // platformWidth를 화면의 1/4 크기로!
    platformWidth = screenWidth / 4;

    // 4개 고정 x좌표 계산
    final List<double> xPositions = [
      0, // 맨 왼쪽
      screenWidth / 4, // 중앙 왼쪽 (왼쪽에서 1/4)
      screenWidth / 2, // 중앙 오른쪽 (왼쪽에서 2/4)
      screenWidth - platformWidth, // 맨 오른쪽
    ];

    // 3. 발판 생성
    for (int i = 0; i < platformPoolSize; i++) {
      final y = lastPlatformY - verticalGap;

      // 1~3개 중 몇 개 생성할지 확률로 결정
      final r = random.nextDouble();
      int count;
      if (r < 0.55) {
        count = 1;
      } else if (r < 0.9) {
        count = 2;
      } else {
        count = 3;
      }

      // x좌표 4개 중 count개를 랜덤하게 뽑기 (중복 없이)
      final List<int> indices = List.generate(4, (i) => i)..shuffle(random);
      for (int j = 0; j < count; j++) {
        final x = xPositions[indices[j]];

        final platform = await Platform.create(
          game: this,
          imagePath: 'assets/spritesheet_jumper.png',
          xmlPath: 'assets/spritesheet_jumper.xml',
          spriteName: 'ground_grass.png',
          position: Vector2(x, y),
          widthScale: platformWidth / screenWidth,
        );
        world.add(platform);
        platforms.add(platform);
      }
      lastPlatformY = y;
    }

    // 장애물 5개 미리 생성
    for (int i = 0; i < 5; i++) {
      final obstacle = await WingmanObstacle.load(
        game: this,
        imagePath: 'assets/spritesheet_jumper.png',
        xmlPath: 'assets/spritesheet_jumper.xml',
        spriteName: 'wingMan1.png',
        position: Vector2(-100, -100), // 화면 밖 대기
        scale: 0.7,
      );
      obstacles.add(obstacle);
    }

    // 제트팩 아이템 2개 풀링
    for (int i = 0; i < 2; i++) {
      final item = await Item.load(
        game: this,
        imagePath: 'assets/spritesheet_jumper.png',
        xmlPath: 'assets/spritesheet_jumper.xml',
        spriteName: 'powerup_jetpack.png',
        position: Vector2(-100, -100), // 화면 밖 대기
        type: 'jetpack',
        scale: 0.7,
      );
      jetpackItems.add(item);
    }

    // 윙 아이템 2개 풀링
    for (int i = 0; i < 2; i++) {
      final item = await Item.load(
        game: this,
        imagePath: 'assets/spritesheet_jumper.png',
        xmlPath: 'assets/spritesheet_jumper.xml',
        spriteName: 'powerup_wings.png',
        position: Vector2(-100, -100),
        type: 'wings',
        scale: 0.7,
      );
      wingsItems.add(item);
    }

    minPlayerY = player.position.y;
    cameraMinY = player.position.y - screenHeight * 0.5;
    camera.moveTo(Vector2(screenWidth / 2, cameraMinY));
  }

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    screenWidth = gameSize.x;
    screenHeight = gameSize.y;
  }

  Future<void> generatePlatform(double y) async {
    final widthScale = 0.5 + random.nextDouble() * 0.5;
    final x = random.nextDouble() * (screenWidth * (1 - widthScale));

    final platform = await Platform.create(
      game: this,
      imagePath: 'assets/spritesheet_jumper.png',
      xmlPath: 'assets/spritesheet_jumper.xml',
      spriteName: 'ground_grass.png',
      position: Vector2(x, y),
      widthScale: widthScale,
    );

    world.add(platform);
    platforms.add(platform);
  }

  void gameOver() {
    if (!isGameOver) {
      isGameOver = true;
      overlays.add('GameOver');
      pauseEngine();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 발판 재활용: 아래로 벗어난 발판을 위로 올림
    for (final platform in platforms) {
      if (platform.position.y > player.position.y + screenHeight) {
        // 가장 위에 있는 발판보다 더 위로 재배치
        platform.position.y = lastPlatformY;
        final x = random.nextDouble() * (screenWidth - platformWidth);
        platform.position.x = x;
        platform.size.x = platformWidth;
        lastPlatformY -= verticalGap;
      }
    }

    // 장애물 재활용: 아래로 벗어난 장애물을 위로 올림
    for (final obstacle in obstacles) {
      if (obstacle.position.y > player.position.y + screenHeight) {
        // 가장 위에 있는 장애물보다 더 위로 재배치
        obstacle.position.y = lastPlatformY;
        obstacle.position.x = screenWidth / 2; // 또는 랜덤 x
        lastPlatformY -= obstacleGap;
      }
    }

    // 발판 생성 관리 (플레이어보다 충분히 위까지 미리 생성)
    if (player.position.y < lastPlatformY - verticalGap * 5 && !isGeneratingPlatform) {
      isGeneratingPlatform = true;
      generatePlatform(lastPlatformY).then((_) {
        lastPlatformY -= verticalGap;
        isGeneratingPlatform = false;
      });
    }

    // 플레이어가 점프(위로 이동)할 때만 발판 제거
    if (player.velocityY < 0) {
      platforms.removeWhere((platform) {
        if (platform.position.y > player.position.y + screenHeight * 0.5) {
          platform.removeFromParent();
          return true;
        }
        return false;
      });
    }

    // 플레이어가 더 높이 올라갔으면 최고점 갱신
    if (player.position.y < minPlayerY) {
      minPlayerY = player.position.y;
    }

    // 카메라를 항상 플레이어 위치에 맞춰 이동 (x는 화면 중앙)
    double targetCameraY = player.position.y - screenHeight * 0.3;
    camera.moveTo(Vector2(screenWidth / 2, targetCameraY));

    // 장애물과 플레이어 충돌 체크
    for (final obstacle in obstacles) {
      // 플레이어와 장애물의 충돌 반경을 8픽셀씩 축소
      final playerRect = player.toRect().deflate(15);
      final obstacleRect = obstacle.toRect().deflate(15);

      if (obstacle.isMounted && playerRect.overlaps(obstacleRect)) {
        gameOver();
        break;
      }
    }

    // 시작 발판이 플레이어보다 너무 위에 있으면 제거
    if (startPlatform.position.y > player.position.y + screenHeight * 0.5) {
      startPlatform.removeFromParent();
    }

    prevPlayerY = player.position.y;
  }

  @override
  void onDragStart(DragStartEvent event) {
    dragStart = event.canvasPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (dragStart != null && event.canvasEndPosition != null) {
      final deltaX = event.canvasEndPosition!.x - dragStart!.x;
      if (deltaX > 20) {
        player.direction = 1;
      } else if (deltaX < -20) {
        player.direction = -1;
      } else {
        player.direction = 0;
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    player.direction = 0;
  }

  double highestPlatformY = double.infinity;
  final VoidCallback? onScoreChanged;

  MyPlatformGame({this.onScoreChanged});

  void onPlatformStepped(double platformY) {
    if (platformY < highestPlatformY) {
      highestPlatformY = platformY;
      score += 10;
      onScoreChanged?.call();

      // 70점마다 장애물 등장
      if (score >= nextObstacleScore) {
        spawnObstacle();
        nextObstacleScore += 70; // 다음 등장 점수 갱신
      }

      // 100점마다 아이템 생성
      if (score >= nextItemScore) {
        spawnItemAbovePlayer();
        nextItemScore += 100;
      }
    }
  }

  void spawnObstacle() {
    // 풀에서 비활성 장애물 찾기
    final obstacle = obstacles.firstWhere(
      (o) => !o.isMounted,
      orElse: () => obstacles[0], // 모두 활성화 상태면 첫 번째 재활용
    );
    obstacle.position = Vector2(
      player.position.x,
      player.position.y - 1000,
    );
    obstacle.direction = random.nextBool() ? 1 : -1;
    if (!obstacle.isMounted) {
      world.add(obstacle);
    }
  }

  void spawnItemAbovePlayer() {
    // 랜덤으로 제트팩 또는 윙 아이템 풀에서 하나 선택
    final isJetpack = random.nextBool();
    final List<Item> pool = isJetpack ? jetpackItems : wingsItems;
    final item = pool.firstWhere((i) => !i.isMounted, orElse: () => pool.first);

    // 플레이어보다 500 위에 위치
    item.position = Vector2(
      player.position.x,
      player.position.y - 1050,
    );
    if (!item.isMounted) {
      world.add(item);
    }
  }
}