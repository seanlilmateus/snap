//
//  MainViewController.m
//  snap
//
//  Created by Mateus Armando on 01.07.12.
//  Copyright (c) 2012 Sean Coorp. INC. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *s_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *n_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *a_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *p_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *joker_imageview;

@property (weak, nonatomic) IBOutlet UIButton *host_game_button;
@property (weak, nonatomic) IBOutlet UIButton *join_game_button;
@property (weak, nonatomic) IBOutlet UIButton *single_player_game_button;

@end

@implementation MainViewController
@synthesize s_imageview;
@synthesize n_imageview;
@synthesize a_imageview;
@synthesize p_imageview;
@synthesize joker_imageview;
@synthesize host_game_button;
@synthesize join_game_button;
@synthesize single_player_game_button;

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
    [self setS_imageview:nil];
    [self setN_imageview:nil];
    [self setA_imageview:nil];
    [self setP_imageview:nil];
    [self setJoker_imageview:nil];
    [self setHost_game_button:nil];
    [self setJoin_game_button:nil];
    [self setSingle_player_game_button:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)host_game:(id)sender {
}
- (IBAction)join_game:(id)sender {
}
- (IBAction)single_player_game:(id)sender {
}

@end
