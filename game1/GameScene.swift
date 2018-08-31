//
//  GameScene.swift
//  game1
//
//  Created by Arthur on 31.08.18.
//  Copyright © 2018 AZ. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var rocket: SKSpriteNode!
    var mars: SKSpriteNode!
    var asteroid: SKSpriteNode!
    var timer = Timer()
    var scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var startLabel: SKLabelNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var score = 0
    var level = 1
    var countdown = 3
    var running = false
    var gravity = -3.0
    
    override func didMove(to view: SKView) {
        setupPhysics()
        layoutScene()
        startGame()
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        createMars()
        createEarth()
        createRocket()
        createBottom()
        
        scoreLabel.text = "score: \(score) level: \(level)"
        scoreLabel.fontSize = 30.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.zPosition = 2
        scoreLabel.position = CGPoint(x: frame.midX, y: 20)
        
        startLabel.text = ""
        startLabel.fontSize = 100.0
        startLabel.fontColor = UIColor.white
        startLabel.zPosition = 1
        startLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(scoreLabel)
        addChild(startLabel)
    }
    
    func startGame() {
        if running { return }
        
        running = true;
        score = 0
        updateScore()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        
        startLabel.isHidden = false
        countdown = 3
    }
    
    func stopGame() {
        running = false
    }
    
    @objc func countDown() {
        countdown -= 1
        startLabel.text = "\(countdown)";
        if countdown == 0 {
            timer.invalidate()
            startLabel.isHidden = true
            createAstroid()
        }
    }
    
    func updateScore() {
        scoreLabel.text = "score: \(score) level: \(level)"
    }
    
    func levelUp() {
        if score % 5 == 0 {
            gravity -= 0.5
            level += 1
            physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity)
            print("level up")
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == PhysicsCategories.bottomCategory | PhysicsCategories.asteroidCategory {
            asteroid.removeFromParent()
            createAstroid()
            
            score += 1
            updateScore()
            levelUp()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            moveRocketTo(x: location.x, y: location.y)
        }
    }
    
    func moveRocketTo(x: CGFloat, y: CGFloat) {
        var angle: CGFloat = x > rocket.position.x ? -45 : 45
        angle = angle * CGFloat.pi / 180
        
        var xPosition = x
        if x < frame.minX {
            xPosition = frame.minX + rocket.size.width
        }
        else if x > frame.maxX {
            xPosition = frame.maxX - rocket.size.width
        }
        
        rocket.physicsBody?.allowsRotation = true
        let angleAction = SKAction.rotate(toAngle: angle, duration: 0.2)
        let moveActionX = SKAction.moveTo(x: xPosition, duration: 0.4)
        let moveActionY = SKAction.moveTo(y: frame.minY+rocket.size.height, duration: 0.4)
        let northAction = SKAction.rotate(toAngle: 0, duration: 0.5)
        let group = SKAction.group([moveActionX, moveActionY])
        let moveSequence = SKAction.sequence([angleAction, group , northAction])
        rocket.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        rocket.physicsBody?.allowsRotation = false
        
        rocket.run(moveSequence)
    }
    
    func createRocket() {
        let texture = SKTexture(imageNamed: "rocket")
        rocket = SKSpriteNode(texture: texture)
        rocket.scale(to: CGSize(width: 100, height: 100))
        rocket.position = CGPoint(x: frame.midX, y: frame.minY+rocket.size.height)
        rocket.zPosition = 2
        
        rocket.physicsBody = SKPhysicsBody(texture: texture, size: rocket.size)
        rocket.physicsBody?.categoryBitMask = PhysicsCategories.rocketCategory
        rocket.physicsBody?.contactTestBitMask = PhysicsCategories.asteroidCategory
        rocket.physicsBody?.isDynamic = true
        rocket.physicsBody?.affectedByGravity = false
        
        addChild(rocket)
    }
    
    func createAstroid() {
        let texture = SKTexture(imageNamed: "asteroid")
        asteroid = SKSpriteNode(texture: texture)
        asteroid.scale(to: CGSize(width: 60, height: 60))
        let size = asteroid.size.width;
        
        let max = Int(frame.width-size)
        let rand = GKRandomDistribution(lowestValue: 50, highestValue: max)
        let xPos = CGFloat(rand.nextInt())
        
        asteroid.zPosition = 2
        asteroid.size = CGSize(width: size, height: size)
        asteroid.position = CGPoint(x: xPos, y: frame.maxY+size)
        
        asteroid.physicsBody = SKPhysicsBody(texture: texture, size: asteroid.size)
        asteroid.physicsBody?.categoryBitMask = PhysicsCategories.asteroidCategory
        asteroid.physicsBody?.isDynamic = true
        
        addChild(asteroid)
        
        let oneRevolution = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 20.0)
        let repeatRotation = SKAction.repeatForever(oneRevolution)
        asteroid.run(repeatRotation)
    }
    
    func createMars() {
        let texture = SKTexture(imageNamed: "mars")
        let mars = SKSpriteNode(texture: texture)
        let size = CGFloat(80)
        
        mars.zPosition = 1
        mars.size = CGSize(width: size, height: size)
        mars.position = CGPoint(x: frame.midX+60, y: frame.maxY-size)
        
        addChild(mars)
        
        let oneRevolution = SKAction.rotate(byAngle: -CGFloat.pi * 2, duration: 60.0)
        let repeatRotation = SKAction.repeatForever(oneRevolution)
        mars.run(repeatRotation)
    }
    
    func createEarth() {
        let texture = SKTexture(imageNamed: "earth")
        let earth = SKSpriteNode(texture: texture)
        let size = CGFloat(30)
        
        earth.zPosition = 1
        earth.size = CGSize(width: size, height: size)
        earth.position = CGPoint(x: frame.midX-60, y: frame.midY+size)
        
        addChild(earth)
        
        let oneRevolution = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 50.0)
        let repeatRotation = SKAction.repeatForever(oneRevolution)
        earth.run(repeatRotation)
    }
    
    func createBottom() {
        let bottom = SKSpriteNode(color: UIColor.white, size: CGSize(width: 10000, height: 10.0))
        bottom.position = CGPoint(x: frame.minX - 100, y: frame.minY)
        bottom.physicsBody = SKPhysicsBody(rectangleOf: bottom.size)
        bottom.physicsBody?.categoryBitMask = PhysicsCategories.bottomCategory
        bottom.physicsBody?.contactTestBitMask = PhysicsCategories.asteroidCategory
        bottom.physicsBody?.isDynamic = false
        
        addChild(bottom)
    }
}
