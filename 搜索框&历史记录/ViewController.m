//
//  ViewController.m
//  搜索框&历史记录
//
//  Created by 胡高广 on 2017/7/28.
//  Copyright © 2017年 胡高广. All rights reserved.
//

#import "ViewController.h"
#import "TCCreatePlist.h"
#import "TwoViewController.h"
#import "TCProgressHUD.h"
#import "AFNetworking.h"
#define WIDHT [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UIView *topView;
    UIView *footView;
}

@property (nonatomic, strong) NSMutableArray *hisArray;
@property (nonatomic, strong) NSMutableArray *searchArr;
@property (nonatomic, strong) UITableView *searchTable;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSUserDefaults *userdefaluts;
@property (nonatomic, strong) UITableView *historyTableView;
@property (nonatomic, strong) UITextField *searchField;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    self.title = @"病情诊断";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.hisArray = [[NSMutableArray alloc] init];
    self.searchArr = [[NSMutableArray alloc] init];
    //建表
    self.path = [TCCreatePlist createPlistFile:@"SearchHistory"];
    NSArray *arr = [NSArray arrayWithContentsOfFile:self.path];
    [self.hisArray addObjectsFromArray: arr];
    //搜索框
    topView = [[UIView alloc] init];
    topView.frame = CGRectMake(10, 64 + 10, WIDHT - 20, 40);
    topView.backgroundColor = [UIColor whiteColor];
    topView.layer.cornerRadius = 3;
    [self.view addSubview:topView];
    
    //搜索的按钮
    UIButton *searchImage = [UIButton buttonWithType:(UIButtonTypeCustom)];
    searchImage.frame = CGRectMake(5, 10, 30, 20);
    [searchImage setImage:[UIImage imageNamed:@"搜索中@2x"] forState:(UIControlStateNormal)];
    [searchImage addTarget:self action:@selector(click) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:searchImage];
    
    //搜索框
    self.searchField = [[UITextField alloc] init];
    self.searchField.frame = CGRectMake(searchImage.frame.size.width + 10, 10, WIDHT - 80, 20);
    self.searchField.clearButtonMode = UITextFieldViewModeAlways;
    self.searchField.delegate = self;
    self.searchField.placeholder = @"请输入诊断名称";
    [self.searchField addTarget:self  action:@selector(valueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
    [topView addSubview:self.searchField];
    
    //创建搜索的tableView
    self.searchTable = [[UITableView alloc]initWithFrame:CGRectMake(0, topView.frame.size.height + topView.frame.origin.y + 10, WIDHT, 400) style:UITableViewStyleGrouped];
    self.searchTable.delegate = self;
    self.searchTable.dataSource = self;
    self.searchTable.rowHeight = 130;
    self.searchTable.tableFooterView = [[UIView alloc]init];
    self.searchTable.hidden = YES;
    self.searchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.searchTable];
    //创建历史记录的tableView
    self.historyTableView = [[UITableView alloc] init];
    if (self.hisArray.count <= 10 && self.hisArray.count > 0) {
        _historyTableView.frame = CGRectMake(0, topView.frame.size.height + topView.frame.origin.y + 10, WIDHT, 50  * (self.hisArray.count + 1));
    }else if(self.hisArray.count > 10){
        _historyTableView.frame = CGRectMake(0, topView.frame.size.height + topView.frame.origin.y + 10, WIDHT, 50  * 11);
    }else{
        _historyTableView.frame = CGRectMake(0,topView.frame.size.height + topView.frame.origin.y + 10, WIDHT, 0);
    }
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    _historyTableView.hidden = NO;
    _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
       [self.view addSubview: _historyTableView];
    // Do any additional setup after loading the view, typically from a nib.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView == self.searchTable){
        return self.searchArr.count;
    }
    if (self.hisArray.count <= 10) {
        return self.hisArray.count + 1;
    }else{
        return 11;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /************** 这里应该有两个tableView，一个是模糊搜索的，一个是历史记录的 ************/
    if(tableView == self.searchTable){
        static NSString *cellIdentity = @"leftCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        }
        //划线
        UIView *lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(10, 49, WIDHT - 20, 1);
        lineView.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:226/255.0 alpha:1.0];
        [cell.contentView addSubview:lineView];
        if(self.searchArr.count == 0){
            NSLog(@"预防出错");
        }else{
            cell.textLabel.text = self.searchArr[indexPath.row];
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.searchArr[indexPath.row]];
            //位置
            NSRange rang = [self.searchArr[indexPath.row] rangeOfString:self.searchField.text];
            //设置属性
            [attributeString setAttributes:[NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor redColor], NSForegroundColorAttributeName, nil] range:rang];
            cell.textLabel.attributedText = attributeString;
        }
            return cell;
    }else{
        UITableViewCell *cells = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cells"];
        if(self.hisArray.count <= 10){
            if (indexPath.row == self.hisArray.count) {
                cells.textLabel.textAlignment = NSTextAlignmentCenter;
                cells.textLabel.text = @"清空记录";
            }else{
                cells.textLabel.text = self.hisArray[indexPath.row];
            }
    }else{
        if (indexPath.row == 10) {
            cells.textLabel.textAlignment = NSTextAlignmentCenter;
            cells.textLabel.text = @"清空记录";
        }else{
            cells.textLabel.text = self.hisArray[indexPath.row];
        }
    }
        cells.textLabel.font = [UIFont systemFontOfSize:13 ];
        //划线
        UIView *lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(10, 49, WIDHT - 20, 1);
        lineView.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:226/255.0 alpha:1.0];
        [cells.contentView addSubview:lineView];
        return cells;

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
        return 50 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(tableView == self.searchTable){
        return 1;
    }
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.searchTable){
        self.searchField.text = self.searchArr[indexPath.row];
        //此处应该消失的tableview消失
//        self.historyTableView.hidden = NO;
        
        [self.hisArray removeAllObjects];
        NSArray *arr = [NSArray arrayWithContentsOfFile: _path];
        [self.hisArray addObjectsFromArray: arr];
        //将新的值插入第一个
        [self.hisArray insertObject:self.searchField.text atIndex:0];
        [self.hisArray writeToFile: _path atomically:YES];
        
        
        //此处应该就是搜索的数据,这里我们作为第二页的跳转来写
        TwoViewController *twoVC = [[TwoViewController alloc] init];
        [self.navigationController pushViewController:twoVC animated:YES];

        
    }else{
        if (self.hisArray.count <= 10) {
            if (indexPath.row == self.hisArray.count) {
                NSFileManager *manager = [NSFileManager defaultManager];
                [manager removeItemAtPath:_path error:nil];
                [self.hisArray removeAllObjects];
                _historyTableView.frame = CGRectMake(0, topView.frame.origin.y + topView.frame.size.height + 10, WIDHT, 0);
                [_historyTableView reloadData];
            }else{
                self.searchField.text = self.hisArray[indexPath.row];
               
            }
        }else{
            if (indexPath.row == 10) {
                NSFileManager *manager = [NSFileManager defaultManager];
                [manager removeItemAtPath:_path error:nil];
                [self.hisArray removeAllObjects];
                _historyTableView.frame = CGRectMake(0, topView.frame.origin.y + topView.frame.size.height + 10, WIDHT, 0);
                [_historyTableView reloadData];
            }else{
                self.searchField.text = self.hisArray[indexPath.row];
                //这里进行搜索的请求
                // [self sousuo];
        //此处应该就是搜索的数据,这里我们作为第二页的跳转来写
        TwoViewController *twoVC = [[TwoViewController alloc] init];
        [self.navigationController pushViewController:twoVC animated:YES];
          }
        }
    }
}


//监听文本框刚开始的变化
-(void)valueChanged:(UITextField *)textField{
    [self.searchArr removeAllObjects];
    _historyTableView.hidden = YES;
    self.searchTable.hidden = NO;
    if(!(textField.text.length == 0)){
            //此处为假数据
       self.searchArr =  [NSMutableArray arrayWithObjects:@"111",@"121",@"131",@"141",nil];
        
       [self.searchTable reloadData];

    }else{
        NSLog(@"没输东西呢");
        self.historyTableView.hidden = NO;
        self.searchTable.hidden = YES;
        [self.historyTableView reloadData];
        [self.searchTable reloadData];
    }
}

    /************** 这里请求接口，即为新数组mohuArray，代表模糊搜索，把搜索历史的tableView打开，把模糊tableView打开，判断两个tableView在下面的cell里判断 ***************/

#pragma mark -- 点击事件
-(void)click
{
    NSLog(@"%@",self.searchField.text);
    if(self.searchField.text.length == 0){
        [TCProgressHUD showMessage:@"搜索的内容不能为空" duration:1.5];
    }else{
        
        //判断是否存在plist文件
        [self.hisArray removeAllObjects];
        NSArray *arr = [NSArray arrayWithContentsOfFile: _path];
        [self.hisArray addObjectsFromArray: arr];
        //将新的值插入第一个
        [self.hisArray insertObject:self.searchField.text atIndex:0];
        [self.hisArray writeToFile: _path atomically:YES];
        NSLog(@"您查找的%@",self.hisArray);
    }
    //此处应该就是搜索的数据,这里我们作为第二页的跳转来写
    TwoViewController *twoVC = [[TwoViewController alloc] init];
    [self.navigationController pushViewController:twoVC animated:YES];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
