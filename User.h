//
//  User.h
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-12.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import <UIKit/UIKit.h> 

@interface User : NSObject
@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSURL *profilePictureURL;
@property (nonatomic, strong) UIImage *profilePicture;
@end
