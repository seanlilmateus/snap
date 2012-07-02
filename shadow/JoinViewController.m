//
//  JoinViewController.m
//  snap
//
//  Created by Mateus Armando on 01.07.12.
//  Copyright (c) 2012 Sean Coorp. INC. All rights reserved.
//

#import "JoinViewController.h"

@interface JoinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *heading_label;
@property (weak, nonatomic) IBOutlet UILabel *name_label;
@property (weak, nonatomic) IBOutlet UITextField *name_text_field;
@property (weak, nonatomic) IBOutlet UILabel *status_label;

@property (weak, nonatomic) IBOutlet UITableView *table_view;

@property (strong, nonatomic) IBOutlet UIView *wait_view;
@property (weak, nonatomic) IBOutlet UILabel *wait_label;

@end

@implementation JoinViewController
@synthesize heading_label;
@synthesize name_label;
@synthesize name_text_field;
@synthesize status_label;
@synthesize table_view;
@synthesize wait_view;
@synthesize wait_label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setHeading_label:nil];
    [self setName_label:nil];
    [self setName_text_field:nil];
    [self setStatus_label:nil];
    [self setTable_view:nil];
    [self setWait_view:nil];
    [self setWait_label:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)exit_action:(id)sender {
}

@end
