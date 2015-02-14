//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Amanda Pi on 2015-02-11.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"

@interface ImagesTableViewController ()
@end

@implementation ImagesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {  // to init images array
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        // self.images = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {  // load our 10 jpgs in the array
    [super viewDidLoad];
    
    //for (int i = 1; i <= 10; i++) {
    //    NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
    //    UIImage *image = [UIImage imageNamed:imageName];
    //    if (image) {
    //       [self.images addObject:image];
    //    }
    //}
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"imageCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSArray *)items {
    return [DataSource sharedInstance].mediaItems;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.images.count;   // make all methods generic
//    return [DataSource sharedInstance].mediaItems.count;
    return [self items].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // compare identifier "imageCell" w tableview cells
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
    
    // Configure the cell...
    static NSInteger imageViewTag = 1234;  // for quick recall
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:imageViewTag];
    
    if (!imageView) {
        // This is a new cell, it doesn't have an image view yet
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        imageView.frame = cell.contentView.bounds; // image takes whole cell
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth; // height n width proportionally stretched
        
        imageView.tag = imageViewTag;  // set tag then add to contentView
        [cell.contentView addSubview:imageView];
    }
    
//    UIImage *image = self.images[indexPath.row];
//    imageView.image = image;
//    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    Media *item = [self items][indexPath.row];
    imageView.image = item.image;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath  { // to return height wrt width of image
//    UIImage *image = self.images[indexPath.row];
//    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    Media *item = [self items][indexPath.row];
    UIImage *image = item.image;

    return (CGRectGetWidth(self.view.frame) / image.size.width) * image.size.height;
//    return image.size.height / image.size.width * CGRectGetWidth(self.view.frame);
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

    // first remove image
    [self.items removeObjectAtIndex:indexPath.row];
    // then remove cell
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
        
        
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
