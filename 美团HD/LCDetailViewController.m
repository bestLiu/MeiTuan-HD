//
//  LCDetailViewController.m
//  美团HD
//
//  Created by mac1 on 15/9/10.
//  Copyright (c) 2015年 BNDK. All rights reserved.
//

#import "LCDetailViewController.h"
#import "LCDeal.h"
#import "LCConst.h"

@interface LCDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor= LCGlobalBg;

    self.webView.hidden = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.deal.deal_h5_url]]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
