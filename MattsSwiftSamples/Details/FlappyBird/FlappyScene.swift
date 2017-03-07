//
//  FlappyScene.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 02/08/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let bird:UInt32 = 1 << 0
    static let world:UInt32 = 1 << 1
    static let pipe:UInt32 = 1 << 2
    static let score:UInt32 = 1 << 3
}

class FlappyScene: SKScene {
    
    fileprivate let skyColor = UIColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    fileprivate let verticalPipeGap:CGFloat = 100
    
    fileprivate let moving = SKNode()
    fileprivate let pipes = SKNode()
    fileprivate var flapSound:SKAction!
    fileprivate var hitSound:SKAction!
    fileprivate var scoreSound:SKAction!

    var score = 0 {
        didSet {
            scoreLabelNode.text = "\(score)"
        }
    }
    var canRestart = false
    var startScreen = true
    
    fileprivate var bird:SKSpriteNode!
    fileprivate var pipeTexture:SKTexture!
    fileprivate var scoreLabelNode:SKLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Wide")

    fileprivate var movePipesAndRemove:SKAction!
    
    fileprivate var initialBirdPosition:CGPoint {
        return CGPoint(x: frame.size.width/4, y: frame.midY)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        
        backgroundColor = skyColor
        
        addChild(moving)
        moving.addChild(pipes)
        
        let atlas = SKTextureAtlas(named: "flappy")
        
        // Bird
        
        let birdTexture1 = atlas.textureNamed("Bird1")
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = atlas.textureNamed("Bird2")
        birdTexture2.filteringMode = .nearest
        
        let flap = SKAction.repeatForever(SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2))
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = initialBirdPosition
        bird.run(flap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.collisionBitMask = PhysicsCategory.world | PhysicsCategory.pipe
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.world | PhysicsCategory.pipe
        
        addChild(bird)
        
        // Ground
        
        let groundTexture = atlas.textureNamed("Ground")
        groundTexture.filteringMode = .nearest
        
        let moveGroundSprite = SKAction.moveBy(x: -groundTexture.size().width*2, y: 0, duration: 0.02 * Double(groundTexture.size().width)*2.0)
        let resetGroundSprites = SKAction.moveBy(x: groundTexture.size().width*2, y: 0, duration: 0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprites]))
        
        for i in 0..<Int(ceil(2+frame.size.width / (groundTexture.size().width*2))) {
            let sprite = SKSpriteNode.init(texture: groundTexture)
            sprite.setScale(2)
            sprite.position = CGPoint(x: CGFloat(i) * sprite.size.width, y: sprite.size.height/2)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // Skyline
        let skylineTexture = atlas.textureNamed("Skyline")
        skylineTexture.filteringMode = .nearest
        
        let moveSkylineSprite = SKAction.moveBy(x: -skylineTexture.size().width*2, y: 0, duration: 0.1 * Double(skylineTexture.size().width)*2.0)
        let resetSkylineSprite = SKAction.moveBy(x: skylineTexture.size().width*2, y: 0, duration: 0)
        let moveSkylineSpriteForever = SKAction.repeatForever(SKAction.sequence([moveSkylineSprite, resetSkylineSprite]))
        
        for i in 0..<Int(ceil(2+frame.size.width / (skylineTexture.size().width*2))) {
            let sprite = SKSpriteNode(texture: skylineTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPoint(x: CGFloat(i)*sprite.size.width, y: sprite.size.height/2+groundTexture.size().height*2)
            sprite.run(moveSkylineSpriteForever)
            moving.addChild(sprite)
        }
        
        // Ground Physics
        
        let dummyNode = SKNode()
        dummyNode.position = CGPoint(x: 0, y: groundTexture.size().height)
        dummyNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.size.width, height: groundTexture.size().height*2))
        dummyNode.physicsBody?.isDynamic = false
        dummyNode.physicsBody?.categoryBitMask = PhysicsCategory.world
        addChild(dummyNode)
        
        // pipes 
        
        pipeTexture = atlas.textureNamed("Pipe")
        pipeTexture.filteringMode = .nearest
        
        let distanceToMove = frame.size.width + 2 * pipeTexture.size().width
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0, duration: 0.01*Double(distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        let spawn = SKAction.perform(#selector(spawnPipes), onTarget: self)
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnAndDelay = SKAction.sequence([spawn, delay])
        let spawnAndDelayForever = SKAction.repeatForever(spawnAndDelay)
        self.run(spawnAndDelayForever)
        
        scoreLabelNode.position = CGPoint(x: frame.midX, y: 3*frame.size.height/4)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = "\(score)"
        addChild(scoreLabelNode)
        
        fly()
    }
    
    func fly() {
        self.bird.physicsBody?.affectedByGravity = false
        let fly = SKAction.sequence([
            SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: -20, duration: 0.5),
                SKAction.moveBy(x: 0, y: 20, duration: 0.5)
                ]))
            ])
        bird.run(fly, withKey: "fly")
    }
    
    func start() {
        startScreen = false
        bird.removeAction(forKey: "fly")
        self.bird.physicsBody?.affectedByGravity = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        DispatchQueue.main.async {
            self.flapSound  = SKAction.playSoundFileNamed("flap.m4a", waitForCompletion: false)
            self.hitSound   = SKAction.playSoundFileNamed("hit.m4a", waitForCompletion: false)
            self.scoreSound = SKAction.playSoundFileNamed("score.m4a", waitForCompletion: false)
        }
    }
    
    func spawnPipes() {
        if startScreen || moving.speed <= 0 { return }
        
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: frame.size.width + pipeTexture.size().width, y: 0)
        pipePair.zPosition = -10
        
        let pipeY:CGFloat = (CGFloat(arc4random()).truncatingRemainder(dividingBy: (self.frame.size.height/3)))
        
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.setScale(2)
        pipe1.position = CGPoint(x:0, y: pipeY)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1.size)
        pipe1.physicsBody?.isDynamic = false
        pipe1.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipe1.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        pipePair.addChild(pipe1)

        let pipe2 = SKSpriteNode(texture: pipeTexture)
        pipe2.setScale(2)
        pipe2.position = CGPoint(x:0, y: pipeY + pipe1.size.height + verticalPipeGap)
        pipe2.yScale = pipe2.yScale * -1
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe2.size)
        pipe2.physicsBody?.isDynamic = false
        pipe2.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipe2.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        pipePair.addChild(pipe2)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint( x: (pipe1.size.width + bird.size.width)/2 , y: frame.midY)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe2.size.width, height: frame.size.height))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        contactNode.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        pipePair.addChild(contactNode)
        
        pipePair.run(movePipesAndRemove)
        pipes.addChild(pipePair)
    }
    
    func resetScene() {
        bird.position = initialBirdPosition
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.collisionBitMask = PhysicsCategory.world | PhysicsCategory.pipe
        bird.speed = 1
        bird.zRotation = 0
        
        pipes.removeAllChildren()
        canRestart = false
        moving.speed = 1
        score = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startScreen {
            start()
        }
        if moving.speed > 0 {
            run(flapSound)
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 4))
        } else if canRestart {
            resetScene()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before everyTime is rendered 
        guard let dyVelocity = bird.physicsBody?.velocity.dy else {
            bird.zRotation = -1
            return
        }
        
        if moving.speed > 0 {
            bird.zRotation =  (dyVelocity * (dyVelocity < 0 ? 0.003 : 0.001)).clamp(-1, 0.5)
        }
    }
}

extension FlappyScene:SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard moving.speed > 0 else { return }
        
        if (contact.bodyA.categoryBitMask & PhysicsCategory.score) == PhysicsCategory.score || (contact.bodyB.categoryBitMask & PhysicsCategory.score) == PhysicsCategory.score {
            score += 1
            run(scoreSound)
            let visualFeedback = SKAction.sequence([SKAction.scaleX(to: 1.5, duration: 0.1), SKAction.scale(to: 1.0, duration: 0.1)])
            scoreLabelNode.run(visualFeedback)
        } else {
            // world collision
            
            moving.speed = 0
            bird.physicsBody?.collisionBitMask = PhysicsCategory.world
            
            let rotateAction = SKAction.rotate(byAngle: CGFloat(M_PI)*bird.position.y*0.01, duration: Double(bird.position.y*0.003))
            bird.run(rotateAction)
            
            self.removeAction(forKey: "flash")
            self.run(SKAction.sequence(
                [
                    hitSound,
                    SKAction.repeat(SKAction.sequence([
                        SKAction.run({ self.backgroundColor = .red }),
                        SKAction.wait(forDuration: 0.05),
                        SKAction.run({ self.backgroundColor = self.skyColor }),
                        SKAction.wait(forDuration: 0.05),
                        ]), count:4),
                    SKAction.run({ self.canRestart = true})
                ])
            )
        }
    }
}
