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
    
    private let skyColor = UIColor(red: 113.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    private let verticalPipeGap:CGFloat = 100
    
    private let moving = SKNode()
    private let pipes = SKNode()
    private var flapSound:SKAction!
    private var hitSound:SKAction!
    private var scoreSound:SKAction!

    var score = 0 {
        didSet {
            scoreLabelNode.text = "\(score)"
        }
    }
    var canRestart = false
    var startScreen = true
    
    private var bird:SKSpriteNode!
    private var pipeTexture:SKTexture!
    private var scoreLabelNode:SKLabelNode = SKLabelNode(fontNamed: "MarkerFelt-Wide")

    private var movePipesAndRemove:SKAction!
    
    private var initialBirdPosition:CGPoint {
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
        birdTexture1.filteringMode = .Nearest
        let birdTexture2 = atlas.textureNamed("Bird2")
        birdTexture2.filteringMode = .Nearest
        
        let flap = SKAction.repeatActionForever(SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2))
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = initialBirdPosition
        bird.runAction(flap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2)
        bird.physicsBody?.dynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.collisionBitMask = PhysicsCategory.world | PhysicsCategory.pipe
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.world | PhysicsCategory.pipe
        
        addChild(bird)
        
        // Ground
        
        let groundTexture = atlas.textureNamed("Ground")
        groundTexture.filteringMode = .Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width*2, y: 0, duration: 0.02 * Double(groundTexture.size().width)*2.0)
        let resetGroundSprites = SKAction.moveByX(groundTexture.size().width*2, y: 0, duration: 0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite, resetGroundSprites]))
        
        for i in 0..<Int(ceil(2+frame.size.width / (groundTexture.size().width*2))) {
            let sprite = SKSpriteNode.init(texture: groundTexture)
            sprite.setScale(2)
            sprite.position = CGPoint(x: CGFloat(i) * sprite.size.width, y: sprite.size.height/2)
            sprite.runAction(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // Skyline
        let skylineTexture = atlas.textureNamed("Skyline")
        skylineTexture.filteringMode = .Nearest
        
        let moveSkylineSprite = SKAction.moveByX(-skylineTexture.size().width*2, y: 0, duration: 0.1 * Double(skylineTexture.size().width)*2.0)
        let resetSkylineSprite = SKAction.moveByX(skylineTexture.size().width*2, y: 0, duration: 0)
        let moveSkylineSpriteForever = SKAction.repeatActionForever(SKAction.sequence([moveSkylineSprite, resetSkylineSprite]))
        
        for i in 0..<Int(ceil(2+frame.size.width / (skylineTexture.size().width*2))) {
            let sprite = SKSpriteNode(texture: skylineTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPoint(x: CGFloat(i)*sprite.size.width, y: sprite.size.height/2+groundTexture.size().height*2)
            sprite.runAction(moveSkylineSpriteForever)
            moving.addChild(sprite)
        }
        
        // Ground Physics
        
        let dummyNode = SKNode()
        dummyNode.position = CGPoint(x: 0, y: groundTexture.size().height)
        dummyNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: frame.size.width, height: groundTexture.size().height*2))
        dummyNode.physicsBody?.dynamic = false
        dummyNode.physicsBody?.categoryBitMask = PhysicsCategory.world
        addChild(dummyNode)
        
        // pipes 
        
        pipeTexture = atlas.textureNamed("Pipe")
        pipeTexture.filteringMode = .Nearest
        
        let distanceToMove = frame.size.width + 2 * pipeTexture.size().width
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0, duration: 0.01*Double(distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        let spawn = SKAction.performSelector(#selector(spawnPipes), onTarget: self)
        let delay = SKAction.waitForDuration(2.0)
        let spawnAndDelay = SKAction.sequence([spawn, delay])
        let spawnAndDelayForever = SKAction.repeatActionForever(spawnAndDelay)
        self.runAction(spawnAndDelayForever)
        
        scoreLabelNode.position = CGPoint(x: frame.midX, y: 3*frame.size.height/4)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = "\(score)"
        addChild(scoreLabelNode)
        
        fly()
    }
    
    func fly() {
        self.bird.physicsBody?.affectedByGravity = false
        let fly = SKAction.sequence([
            SKAction.repeatActionForever(SKAction.sequence([
                SKAction.moveByX(0, y: -20, duration: 0.5),
                SKAction.moveByX(0, y: 20, duration: 0.5)
                ]))
            ])
        bird.runAction(fly, withKey: "fly")
    }
    
    func start() {
        startScreen = false
        bird.removeActionForKey("fly")
        self.bird.physicsBody?.affectedByGravity = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        dispatch_async(dispatch_get_main_queue()) {
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
        
        let pipeY:CGFloat = (CGFloat(arc4random()) % (self.frame.size.height/3))
        
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.setScale(2)
        pipe1.position = CGPoint(x:0, y: pipeY)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1.size)
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipe1.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        pipePair.addChild(pipe1)

        let pipe2 = SKSpriteNode(texture: pipeTexture)
        pipe2.setScale(2)
        pipe2.position = CGPoint(x:0, y: pipeY + pipe1.size.height + verticalPipeGap)
        pipe2.yScale = pipe2.yScale * -1
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe2.size)
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipe2.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        pipePair.addChild(pipe2)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint( x: (pipe1.size.width + bird.size.width)/2 , y: frame.midY)
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: pipe2.size.width, height: frame.size.height))
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        contactNode.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        pipePair.addChild(contactNode)
        
        pipePair.runAction(movePipesAndRemove)
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if startScreen {
            start()
        }
        if moving.speed > 0 {
            runAction(flapSound)
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 4))
        } else if canRestart {
            resetScene()
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
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
    
    func didBeginContact(contact: SKPhysicsContact) {
        guard moving.speed > 0 else { return }
        
        if (contact.bodyA.categoryBitMask & PhysicsCategory.score) == PhysicsCategory.score || (contact.bodyB.categoryBitMask & PhysicsCategory.score) == PhysicsCategory.score {
            score += 1
            runAction(scoreSound)
            let visualFeedback = SKAction.sequence([SKAction.scaleXTo(1.5, duration: 0.1), SKAction.scaleTo(1.0, duration: 0.1)])
            scoreLabelNode.runAction(visualFeedback)
        } else {
            // world collision
            
            moving.speed = 0
            bird.physicsBody?.collisionBitMask = PhysicsCategory.world
            
            let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI)*bird.position.y*0.01, duration: Double(bird.position.y*0.003))
            bird.runAction(rotateAction)
            
            self.removeActionForKey("flash")
            self.runAction(SKAction.sequence(
                [
                    hitSound,
                    SKAction.repeatAction(SKAction.sequence([
                        SKAction.runBlock({ self.backgroundColor = .redColor() }),
                        SKAction.waitForDuration(0.05),
                        SKAction.runBlock({ self.backgroundColor = self.skyColor }),
                        SKAction.waitForDuration(0.05),
                        ]), count:4),
                    SKAction.runBlock({ self.canRestart = true})
                ])
            )
        }
    }
}
