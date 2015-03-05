//
//  CircleSpinnerView.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-03-03.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "CircleSpinnerView.h"

@interface CircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation CircleSpinnerView

- (CAShapeLayer*)circleLayer {
    if(!_circleLayer) {
        // calculate center of the circle
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        // create rect from circle
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
        // a bezier path have both straight and curce lines. Create new bezier path of an arc
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2  // radians
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        // CAShapeLayer is a core animation layer made from bezier path
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.contentsScale = [[UIScreen mainScreen] scale]; //1.0 and 2.0
        _circleLayer.frame = rect;
        _circleLayer.fillColor = [UIColor yellowColor].CGColor;
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        _circleLayer.lineCap = kCALineCapRound;
        _circleLayer.lineJoin = kCALineJoinBevel;
        _circleLayer.path = smoothedPath.CGPath;
        
        // give layer the path from our UIBezierPath object
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"] CGImage]; // mask with gradient
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        // animate the mask in circular motion
        CFTimeInterval animationDuration = 1;  // second
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = @0;     // from here
        animation.toValue = @(M_PI*2);  // to here is one full circular turn
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards; // leave layer on screen after animation
        animation.autoreverses = NO;
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"]; // add animation to layer
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        // create CABasciAnimation which animates the start of the stroke
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        // create another CABasicAnimation which animates the end
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        // add both animations to a CAAnimationGroup
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        // add animations to the circle layer
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _circleLayer;
}

- (void)layoutAnimatedLayer {
    // position the circle layer in center of view
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // when add a subview to another view using [UIView -addSubView:], the subview can react to this in [UIView -willMoveToSuperview:]
    if (newSuperview != nil) {
        [self layoutAnimatedLayer];
    }
    else {
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
}

- (void)setFrame:(CGRect)frame {
    // update position of layer if the frame changes
    [super setFrame:frame];
    
    if (self.superview != nil) {
        [self layoutAnimatedLayer];
    }
}

- (void)setRadius:(CGFloat)radius {
    // update positioning when radius change
    _radius = radius;
    
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
    [self layoutAnimatedLayer];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    // inform self.circleLayer when stroke changes
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
     // inform self.circleLayer when color changes
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeThickness = 3;   // set some default values
        self.radius = 15;
        self.strokeColor = [UIColor orangeColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {  // hint on size
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
