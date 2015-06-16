//
//  ViewController.m
//  GuessImagesGame
//
//  Created by 王涛 on 15/1/1.
//  Copyright (c) 2015年 王涛. All rights reserved.
//

#import "ViewController.h"
#import "GuessModel.h"
@interface ViewController ()
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,weak) UIButton *backButton;
@property (nonatomic,assign) int goldMarks;
@property (nonatomic,assign) int index;
@property (nonatomic,strong) NSArray *imgInformation;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIButton *GoldCount;
@property (weak, nonatomic) IBOutlet UIButton *promptButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *inforLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *imgButton;
- (IBAction)operate:(UIButton *)btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initOptionsView];
    self.goldMarks=100;
    [self score:self.goldMarks];
    [self setGuessView:self.index];
    // Do any additional setup after loading the view, typically from a nib.
}
//懒加载ImgInformation
-(void)initImgInformation{
    if (_imgInformation==nil) {
        NSString *path=[[NSBundle mainBundle]pathForResource:@"questions" ofType:@"plist"];
        _imgInformation=[NSArray arrayWithContentsOfFile:path];
        NSMutableArray *temp=[NSMutableArray array];
        for (NSDictionary *dic in _imgInformation) {
            _guM=[[GuessModel alloc]initWithDic:dic];
            [temp addObject:_guM];
        }
        _imgInformation=temp;
    }
}
//懒加载optionsView
-(void)initOptionsView{
    if (_optionsView.subviews.count==0) {
        int totalCol=7;
        CGFloat tempW=self.answerView.frame.size.height;
        CGFloat tempH=tempW;
        CGFloat spaceX=10;
        CGFloat spaceY=15;
        CGFloat Xmargin=(self.optionsView.frame.size.width-tempW*totalCol-spaceX*(totalCol-1))*0.5;
        CGFloat Ymargin=(self.optionsView.frame.size.height-tempH*3-spaceY*2)*0.5;
        for (int i=0; i<21; i++) {
            UIButton *temp=[[UIButton alloc]init];
            int row=i/totalCol;
            int col=i%totalCol;
            CGFloat tempX=Xmargin+(tempW+spaceX)*col;
            CGFloat tempY=Ymargin+(tempH+spaceY)*row;
            temp.frame=CGRectMake(tempX, tempY, tempW, tempH);
            [temp setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
            [temp addTarget:self action:@selector(guess:) forControlEvents:UIControlEventTouchUpInside];
            [self.optionsView addSubview:temp];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//得分
-(void)score:(int)marks{
    self.goldMarks=marks;
    [self.GoldCount setTitle:[NSString stringWithFormat:@"%d",self.goldMarks] forState:UIControlStateNormal];
}
-(void)setGuessView:(int)index{
    self.count=0;
    self.goldMarks=[[self.GoldCount titleForState:UIControlStateNormal] intValue];
    if (self.goldMarks==0) {
        self.promptButton.enabled=NO;
    }else{
        self.promptButton.enabled=YES;
    }
    for (UIButton *btn in self.answerView.subviews) {
        [btn removeFromSuperview];
    }
    [self initImgInformation];
    self.guM=[[GuessModel alloc]init];
    self.guM=self.imgInformation[index];
    self.titleLabel.text=[NSString stringWithFormat:@"%d/%ld",index+1,self.imgInformation.count];
    self.inforLabel.text=self.guM.title;
[self.imgButton setImage:[UIImage imageNamed:self.guM.icon] forState:UIControlStateNormal];
    //设置answerView
    NSInteger answerLength=self.guM.answer.length;
    CGFloat tempW=self.answerView.frame.size.height;
    CGFloat tempH=tempW;
    CGFloat spaceX=30;
    CGFloat Xmargin=(self.answerView.frame.size.width-tempW*answerLength-spaceX*(answerLength-1))*0.5;
    for (int i=0; i<answerLength; i++) {
        UIButton *temp=[[UIButton alloc]init];
        CGFloat tempX=Xmargin+(tempW+spaceX)*i;
        temp.frame=CGRectMake(tempX, 0, tempW, tempH);
        [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [temp setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [temp addTarget:self action:@selector(alter:) forControlEvents:UIControlEventTouchUpInside];
        [self.answerView addSubview:temp];
    }
//设置optionsView
    int i=0;
    for (UIButton *tempbtn in self.optionsView.subviews) {
        NSString *temp=self.guM.options[i++];
        tempbtn.hidden=NO;
        [tempbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tempbtn setTitle:temp forState:UIControlStateNormal];
    }
    self.nextButton.enabled=self.index!=self.imgInformation.count-1;
    
}
//添加options点击事件方法
-(void)guess:(UIButton *)btn{
    NSString *temp=btn.titleLabel.text;
    
    //NSLog(@"%@",temp);
    for (UIButton *tempBtn in self.answerView.subviews) {
        NSString *str=[tempBtn titleForState:UIControlStateNormal];//先取出来,才能用.length方法
        if (str.length==0) {
            [tempBtn setTitle:temp forState:UIControlStateNormal];
            btn.hidden=YES;
            self.count+=1;
            //NSLog(@"%lu,%lu",self.count,self.guM.answer.length);
            if (self.count==self.guM.answer.length){
                NSMutableString *temp=[NSMutableString string];
                NSString *str=[[NSString alloc]init];
                for (UIButton *tempbtn in self.answerView.subviews) {
                     str=tempbtn.titleLabel.text;
                    [temp appendString:str];
                }
                str=temp;
                if ([str isEqual:self.guM.answer]) {//判断是否正确
                    for (UIButton *tempBtn in self.answerView.subviews) {
                        [tempBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                    }
                    self.goldMarks+=100;
                    [self score:self.goldMarks];
                    
                   [UIView animateWithDuration:0.5 animations:^{
                       self.index++;
                    //弹框显示游戏结束
                       if (self.index==self.imgInformation.count) {
                           UIAlertController *alc=[UIAlertController alertControllerWithTitle:@"提示" message:@"恭喜您通关了!" preferredStyle:UIAlertControllerStyleAlert];
                           [alc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                           [alc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                           [self presentViewController:alc animated:YES completion:nil];
                       }else{
                       [self setGuessView:self.index];
                       }
                   }];
                    
                }else{
                for (UIButton *tempBtn in self.answerView.subviews) {
                    [tempBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                }
            }
                break;
            }
    }
}
//添加answer点击方法
-(void)alter:(UIButton *)btn{
    self.count-=1;
    //self.optionsView.userInteractionEnabled = YES;
    for (UIButton *tempBtn in self.optionsView.subviews) {
        if ([tempBtn.titleLabel.text isEqual:btn.titleLabel.text]&&tempBtn.hidden==YES) {
        tempBtn.hidden=NO;
        break;
        }
    }
    [btn setTitle:@"" forState:UIControlStateNormal];
    //    3.让答案按钮变成黑色
    for (UIButton *btn in self.answerView.subviews) {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
}
//提示
-(void)prompt:(UIButton *)btn{
    self.goldMarks-=100;
    if(self.goldMarks<=0){
        self.goldMarks=0;
        btn.enabled=NO;
    }
    self.count+=1;
    [self score:self.goldMarks];
    NSString *str=[self.guM.answer substringToIndex:1];
    UIButton *temp= self.answerView.subviews.firstObject;
    for (UIButton *teB in self.answerView.subviews) {
        for (UIButton *tempB in self.optionsView.subviews) {
            if ([tempB.titleLabel.text isEqual:teB.titleLabel.text]&&tempB.hidden==YES) {
               tempB.hidden=NO;
            }
        }
[teB setTitle:@"" forState:UIControlStateNormal];
      
    }
    [temp setTitle:str forState:UIControlStateNormal];
    for (UIButton *tempB in self.optionsView.subviews) {
        if ([tempB.titleLabel.text isEqual:str]) {
            tempB.hidden=YES;
        }
    }
    
}
- (IBAction)operate:(UIButton *)btn {
    switch (btn.tag) {
        case 0:
            if (_backButton==nil) {
                [self big];
            }else{
                [self small];
            }
            break;
        case 1:[self prompt:btn];
            ;break;
        case 2:
            
            break;
        case 3:
            [self big];
            break;
        case 4:self.index++;
            [self setGuessView:self.index];
            
            break;
   
    }
}
//放大图片
-(void)big{
    UIButton *backButton=[[UIButton alloc]init];
    backButton.frame=self.view.frame;
    [backButton setBackgroundColor:[UIColor blackColor]];
    [backButton addTarget:self action:@selector(small) forControlEvents:UIControlEventTouchUpInside];
    backButton.alpha=0.0;
    self.backButton=backButton;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.5];
    backButton.alpha=0.7;
    [self.view addSubview: backButton];
    [self.view bringSubviewToFront:self.imgButton];
    self.imgButton.frame=CGRectMake(0, 146, 375, 375);
    [UIView commitAnimations];
}
//缩小图片
-(void)small{
    [UIView animateWithDuration:1.0 animations:^{
        self.backButton.alpha=0.0;
        self.imgButton.frame=CGRectMake(112, 134, 150, 150);
    } completion:^(BOOL finished) {
        if (finished) {
            [self.backButton removeFromSuperview];
        }
    }];
}

@end
