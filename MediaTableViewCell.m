//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-14.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "DataSource.h"
#import "LikeButton.h"
#import "ComposeCommentView.h"

@interface MediaTableViewCell () <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) LikeButton *likeButton;
@property (nonatomic, strong) UILabel *likecountLabel;
@property (nonatomic, strong) ComposeCommentView *commentView;

@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;

@implementation MediaTableViewCell


+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]; /*#eeeeee*/
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1]; /*#58506d*/
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    [super setSelected:NO animated:animated];
    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mediaImageView = [[UIImageView alloc] init];
        
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        // Assignment retry download by tapping with 2 fingers
        self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
        self.doubleTapGestureRecognizer.delegate = self;
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:self.doubleTapGestureRecognizer];

        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        // self.commentLabel.backgroundColor = commentLabelGray; //white is better
        
        // create likeButton
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        // create likeCount
        self.likecountLabel = [[UILabel alloc] init];
        self.likecountLabel.backgroundColor = usernameLabelGray;
        
        
        self.commentView = [[ComposeCommentView alloc] init];
        self.commentView.delegate = self;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.likecountLabel, self.commentView]) {

            [self.contentView addSubview:view];
             view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        // define dictionary for using tricks
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likecountLabel, _likeButton, _commentView);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|"
                      options:kNilOptions
                      metrics:nil
                      views:viewDictionary]];
        
       // [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeCount][_likeButton(==38)]|"
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likecountLabel(==38)][_likeButton(==38)]|"
                      // options:kNilOptions
                      options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                      metrics:nil
                      views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|"
                      options:kNilOptions
                      metrics:nil
                      views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentView]|"
                      options:kNilOptions
                      metrics:nil
                      views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]"
                      options:kNilOptions
                      metrics:nil
                      views:viewDictionary]];
        
        // Height constraints: height=(nil*1)+100
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                      attribute:NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:nil
                      attribute:NSLayoutAttributeNotAnAttribute
                      multiplier:1
                      constant:100];
        
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                      attribute:NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:nil
                      attribute:NSLayoutAttributeNotAnAttribute
                      multiplier:1
                      constant:100];
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                      attribute:NSLayoutAttributeHeight
                      relatedBy:NSLayoutRelationEqual
                      toItem:nil
                      attribute:NSLayoutAttributeNotAnAttribute
                      multiplier:1
                      constant:100];
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
        
    }
    return self;
}

#pragma mark - Liking

- (void) likePressed:(UIButton *)sender { // inform delegate when button is tapped
    [self.delegate cellDidPressLikeButton:self];
}


#pragma mark - Image View

- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    // inform delegate when gesture recognizer fires
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

- (void) doubleTapFired:(UIGestureRecognizer *)sender {
    [[DataSource sharedInstance] downloadImageForMediaItem:self.mediaItem];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // Before layout, calculate the intrinsic size of the labels (the size they "want" to be), and add 20 to the height for some vertical padding.
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
    
    if (_mediaItem.image) {
        self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    } else {
        self.imageHeightConstraint.constant = 100; // Assignment set to non-zero for smoother scrolling
    }

    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}

#pragma mark - Strings

- (NSAttributedString *) usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    
    // Make a string that says "username caption text"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // Make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;
}


- (NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment text" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        // Make an attributed string, with the "username" bold
        
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}


- (NSAttributedString *) likecountLabelString {
    // Make a string to show number of like counts on likecountLabel
    CGFloat likeNumberFontSize = 15;
    NSString *baseString = [NSString stringWithFormat:@"%ld", (unsigned long)self.mediaItem.likeNumber];
    NSMutableAttributedString *mutableLikecountLabelString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [boldFont fontWithSize:likeNumberFontSize], NSParagraphStyleAttributeName: paragraphStyle}];
    return mutableLikecountLabelString;
}


- (void) setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState;  // display correct state on button
    self.likecountLabel.attributedText = [self likecountLabelString];
    self.commentView.text = mediaItem.temporaryComment; // update text when cell is created or reused
}


+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    layoutCell.mediaItem = mediaItem;
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // Get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentView.frame);
}

#pragma mark - ComposeCommentViewDelegate

- (void) commentViewDidPressCommentButton:(ComposeCommentView *)sender {
    [self.delegate cell:self didComposeComment:self.mediaItem.temporaryComment];
    // delegate is the images table controller
}

- (void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text {
    self.mediaItem.temporaryComment = text; // temporary so that user can scroll and not losing comments still writing
}

- (void) commentViewWillStartEditing:(ComposeCommentView *)sender {
    [self.delegate cellWillStartComposingComment:self];
}

- (void) stopComposingComment {
    [self.commentView stopComposingComment];
    // if cell was told stopComposingComment, cell passes message to comment view
}

- (void)awakeFromNib {
    // Initialization code
}


@end
