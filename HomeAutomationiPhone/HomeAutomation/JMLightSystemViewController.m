//
//  JMLightSystemViewController.m
//  HomeAutomation
//
//  Created by Jamie Maddocks on 27/11/2013.
//  Copyright (c) 2013 Jamie Maddocks. All rights reserved.
//

#import "JMLightSystemViewController.h"
#import "JMLightViewController.h"

@interface JMLightSystemViewController ()

@end

@implementation JMLightSystemViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LightCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Living Room";
            break;
        case 1:
            cell.textLabel.text = @"Dining Room";
            break;
        case 2:
            cell.textLabel.text = @"Kitchen";
            break;
        case 3:
            cell.textLabel.text = @"Bedroom 1";
            break;
        case 4:
            cell.textLabel.text = @"Bedroom 2";
            break;
        case 5:
            cell.textLabel.text = @"Bathroom";
            break;
    }
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    [[segue destinationViewController] setTitle:cell.textLabel.text];
    [(JMLightViewController *)[segue destinationViewController] setRoomNumber:self.tableView.indexPathForSelectedRow.row];
}


@end
