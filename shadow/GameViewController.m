//
//  GameViewController.m
//  shadow
//
//  Created by Mateus Armando on 16.07.12.
//  Copyright (c) 2012 Sean Coorp. INC. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *center_label;
@property (weak, nonatomic) IBOutlet UIImageView *bg_image_view;
@property (weak, nonatomic) IBOutlet UIView *card_container_view;
@property (weak, nonatomic) IBOutlet UIImageView *correct_snap_image_view;
@property (weak, nonatomic) IBOutlet UIImageView *bottom_player_active_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *left_player_active_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *right_player_active_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *top_player_active_imageview;
@property (weak, nonatomic) IBOutlet UILabel *bottom_player_name_label;
@property (weak, nonatomic) IBOutlet UILabel *left_player_name_label;
@property (weak, nonatomic) IBOutlet UIButton *next_round_button;
@property (weak, nonatomic) IBOutlet UILabel *right_player_name_label;
@property (weak, nonatomic) IBOutlet UILabel *top_player_name_label;
@property (weak, nonatomic) IBOutlet UILabel *bottom_player_wins_label;
@property (weak, nonatomic) IBOutlet UILabel *left_player_wins_label;
@property (weak, nonatomic) IBOutlet UILabel *right_player_wins_label;
@property (weak, nonatomic) IBOutlet UILabel *top_player_wins_label;
@property (weak, nonatomic) IBOutlet UIImageView *wrong_snap_image_view;
@property (weak, nonatomic) IBOutlet UIButton *turn_over_button;
@property (weak, nonatomic) IBOutlet UIButton *snap_button;
@property (weak, nonatomic) IBOutlet UIImageView *bottom_snap_indicator_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *left_snap_indicator_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *right_snap_indicator_imageview;
@property (weak, nonatomic) IBOutlet UIImageView *top_snap_indicator_imageview;

@end

@implementation GameViewController
@synthesize center_label;
@synthesize bg_image_view;
@synthesize card_container_view;
@synthesize correct_snap_image_view;
@synthesize right_player_name_label;
@synthesize top_player_name_label;
@synthesize bottom_player_wins_label;
@synthesize left_player_wins_label;
@synthesize right_player_wins_label;
@synthesize top_player_wins_label;
@synthesize wrong_snap_image_view;
@synthesize turn_over_button;
@synthesize snap_button;
@synthesize bottom_snap_indicator_imageview;
@synthesize left_snap_indicator_imageview;
@synthesize right_snap_indicator_imageview;
@synthesize top_snap_indicator_imageview;
@synthesize bottom_player_active_imageview;
@synthesize left_player_active_imageview;
@synthesize right_player_active_imageview;
@synthesize top_player_active_imageview;
@synthesize bottom_player_name_label;
@synthesize left_player_name_label;
@synthesize next_round_button;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)exit_action:(id)sender {
}
- (IBAction)next_round_action:(id)sender {
}
- (IBAction)snap_action:(id)sender {
}
- (IBAction)turn_over_action:(id)sender {
}
- (IBAction)turn_over_enter:(id)sender {
}
- (IBAction)turn_over_exit:(id)sender {
}
- (IBAction)turn_over_pressed:(id)sender {
}

- (void)viewDidUnload {
    [self setCenter_label:nil];
    [self setBg_image_view:nil];
    [self setCard_container_view:nil];
    [self setCorrect_snap_image_view:nil];
    [self setNext_round_button:nil];
    [self setBottom_player_active_imageview:nil];
    [self setLeft_player_active_imageview:nil];
    [self setRight_player_active_imageview:nil];
    [self setTop_player_active_imageview:nil];
    [self setBottom_player_name_label:nil];
    [self setLeft_player_name_label:nil];
    [self setNext_round_button:nil];
    [self setRight_player_name_label:nil];
    [self setTop_player_name_label:nil];
    [self setBottom_player_wins_label:nil];
    [self setLeft_player_wins_label:nil];
    [self setRight_player_wins_label:nil];
    [self setTop_player_wins_label:nil];
    [self setWrong_snap_image_view:nil];
    [self setTurn_over_button:nil];
    [self setSnap_button:nil];
    [self setBottom_snap_indicator_imageview:nil];
    [self setLeft_snap_indicator_imageview:nil];
    [self setRight_snap_indicator_imageview:nil];
    [self setTop_snap_indicator_imageview:nil];
    [super viewDidUnload];
}
@end
