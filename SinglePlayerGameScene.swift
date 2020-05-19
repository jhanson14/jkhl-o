//
//  SinglePlayerGameScene.swift
//  PongGG
//
//  Created by Jackson Hanson on 5/9/20.
//  Copyright © 2020 Mounir, Reda. All rights reserved.
//
import Foundation
import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

let BallCategory   : UInt32 = 0x1 << 0
let BottomCategory : UInt32 = 0x1 << 1
let BlockCategory  : UInt32 = 0x1 << 2
let PaddleCategory : UInt32 = 0x1 << 3
let BorderCategory : UInt32 = 0x1 << 4



let scoreLabel = SKLabelNode(text: "Score:")
var currentScore: Int = 0{
  didSet{
    scoreLabel.text = "Score: \(currentScore)"
    scoreLabel.fontName = "Futura-MediumItalic"
    scoreLabel.fontSize = 24
    scoreLabel.name = "scoreLabel"
    
  }
}

var ballInPlay = false



class SinglePlayerGameScene: SKScene, SKPhysicsContactDelegate {
  var numRows = 1
  var isFingerOnPaddle = false
  let scoreLabel = SKLabelNode(text: "Score:")
  var blockCount = 0
  
  // MARK: - Setup
  override func didMove(to view: SKView) {
    ballInPlay = true
    super.didMove(to: view)
    
    // sets border around the screen
    let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    
    borderBody.friction = 0
    
    setupLabels()
    
    self.physicsBody = borderBody
    
    // set world gravity and collision
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    
    // make ball and launch it
    let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
    ball.physicsBody!.applyImpulse(CGVector(dx: 10, dy: -500.0))
    
    // sets bottom physics
    let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 10)
    let bottom = SKNode()
    bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
    addChild(bottom)
    
    // make paddle
    let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
    
    // sets category bit masks, bitmasks make it easy to store and change information using a single variable
    bottom.physicsBody!.categoryBitMask = BottomCategory
    ball.physicsBody!.categoryBitMask = BallCategory
    paddle.physicsBody!.categoryBitMask = PaddleCategory
    borderBody.categoryBitMask = BorderCategory
    
    
    ball.physicsBody!.applyImpulse(CGVector(dx: 5.0, dy: 10.0))
    
    ballInPlay = true
    buildBlocks(numRows: numRows)
    
    
    ball.physicsBody!.contactTestBitMask = BottomCategory | BlockCategory
  
  }
  func buildBlocks(numRows: Int) {
    let numberOfBlocks = 8
       var numRows = numRows
       var yposit = CGFloat(frame.height * 0.8)
       let blockWidth = CGFloat(50)
       let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
       let xOffset = (frame.width - totalBlocksWidth) / 2

    for  n in 0..<numRows {
    for i in 0..<numberOfBlocks {
      let block = SKSpriteNode(imageNamed: "03-Breakout-Tiles.png")
      block.position = CGPoint(x: xOffset + CGFloat(CGFloat(i) + 0.5) * blockWidth,
                               y: yposit)
      block.xScale = 0.15
      block.yScale = 0.25
      
      block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
      block.physicsBody!.allowsRotation = false
      block.physicsBody!.friction = 0.0
      block.physicsBody!.affectedByGravity = false
      block.physicsBody!.isDynamic = false
      block.name = BlockCategoryName
      block.physicsBody!.categoryBitMask = BlockCategory
      block.zPosition = 2
      addChild(block)
      blockCount += 1
      
      
      
      
      
    }
      yposit -= CGFloat(-43.00)
    }
    
  }
  
  
  // MARK: Events
  // gets location of touch even and decides if its on the paddle
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first
    let touchLocation = touch!.location(in: self)
    
    //
    if let body = physicsWorld.body(at: touchLocation) {
      if body.node!.name == PaddleCategoryName {
        print("Began touch on paddle")
        isFingerOnPaddle = true
      }
    }
    
    enumerateChildNodes(withName: "scoreLabel", using: { (node, stop) in
    if node.name == "scoreLabel" {
      if node.contains(touch!.location(in: self)) {
        let transistion = SKTransition.fade(withDuration: 0.5)
        let gameScene = SinglePlayerGameScene(fileNamed: "MainMenu")
        self.view?.presentScene(gameScene!, transition: transistion)
      }
    }
    })}
  
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    // if player is touching paddle updates the paddle location using the difference of touch locations
    if isFingerOnPaddle {
      
      let touch = touches.first
      let touchLocation = touch!.location(in: self)
      let previousLocation = touch!.previousLocation(in: self)
      
      let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
      
      var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
      
      // sets max x value for paddle to keep it on the screen
      paddleX = max(paddleX, paddle.size.width/2)
      paddleX = min(paddleX, size.width - paddle.size.width/2)
      // 6.
      paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
    }
  }
  
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    isFingerOnPaddle = false
  }
  // collision
  // MARK: - SKPhysicsContactDelegate
  func didBegin(_ contact: SKPhysicsContact) {
    
    // the 2 bodies in collision
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    
    // check to see which one has lower bitmask and stores it in firstbody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    // ball hitting bottom
    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {
      print("lose one life")
    }
    // ball hitting blocks
    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
      breakBlock(node: secondBody.node!)
      if blockCount == 0 {
        print("winner")
        numRows += 1
        buildBlocks(numRows: numRows)
        
      }
      
    }
    
    // ball hitting other sides of the screen
    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BorderCategory {
      //            print("hit border")
      
    }
    
    // ball hitting paddle
    if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PaddleCategory {
      print("hit paddle")
    }
  }
  // MARK: helpers
  
  
  func breakBlock(node: SKNode) {
    let particles = SKEmitterNode(fileNamed: "MyParticle")!
    particles.position = node.position
    particles.zPosition = 3
    addChild(particles)
    particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                     SKAction.removeFromParent()]))
    node.removeFromParent()
    currentScore += 10
    scoreLabel.text = "Score: \(currentScore)"
    blockCount -= 1
    
    print(currentScore)
    

  }
  func setupLabels(){
    
    
    
    
    scoreLabel.position = CGPoint(x: size.width - (size.width * 0.9), y: size.height - (size.height * 0.9) )
    scoreLabel.fontName = "Futura-MediumItalic"
    scoreLabel.fontSize = 24
    addChild(scoreLabel)
    
    
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    // manages ball speed and stops ball from staying in a straight line
    if(ballInPlay) {
      
      let ball = childNode(withName: "ball") as! SKSpriteNode
      let maxSpeed: CGFloat = 1300.0
      let xSpeed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx)
      let ySpeed = sqrt(ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)
      
      let speed = sqrt((ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx) + (ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy))
      
      if xSpeed <= 400 {
        ball.physicsBody!.applyImpulse(CGVector(dx: Double(Float.random(in: 0 ..< 100)), dy: 0.0))
        
      }
      if ySpeed <= 400 {
        ball.physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: Double(Float.random(in: 25 ..< 300))))
        
      }
      
      if speed > maxSpeed {
        ball.physicsBody!.linearDamping = 0.4
        
      } else {
        ball.physicsBody!.linearDamping = 0.0
      }
      
    }
  }
}
