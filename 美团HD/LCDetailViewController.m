//
//  LCDetailViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/10.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface LCDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end

@implementation LCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= LCGlobalBg;

    self.webView.hidden = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.deal.deal_h5_url]]];
    [self setupLeftSubViews];
}

- (void)setupLeftSubViews
{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.deal.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
}

/**
 *  支持那些方向
 *
 *  @return 返回控制器的支持方向
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - UIWebViewDelegate

- (IBAction)backButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if([webView.request.URL.absoluteString isEqualToString:self.deal.deal_h5_url])
    {
        //旧的html5页面加载完毕
           NSString *theID = [self.deal.deal_id substringFromIndex:[self.deal.deal_id rangeOfString:@"-"].location + 1];
            NSString *urlStr = [NSString stringWithFormat:@"http://lite.m.dianping.com/group/deal/moreinfo/%@",theID];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    }else{//详情页面加载完毕
        //显示webView
        webView.hidden = NO;
        
        //隐藏正在加载
        [self.loadingView stopAnimating];
        
//        利用webView执行JS
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML"];
        NSLog(@"html %@",html);
        
    }
}



@end
