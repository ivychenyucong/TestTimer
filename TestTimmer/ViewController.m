//
//  ViewController.m
//  TestTimmer
//
//  Created by ivy on 16/10/19.
//  Copyright © 2016年 ivy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSTimer * timer;

@property (nonatomic, strong) NSArray * randomTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.randomTime = @[@(2),@(3),@(4), @(2)];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    // 定时器
     //[self testTimmerWithScheduleNORepeat];
    //[self testTimmerWithScheduleRepeat];
    //[self testTimmerWithFire];
    //[self testTimerGCD];
    //[self pauseTimer];
    [self randomTimeTimer];
    //[self testTimmer2];
    
    //NSInvocation
    //[self testInvocation];
    
    //NSInvocation multiple param
    //[self testInvocationWithParam];
    
    //NSInvocation return value
    //[self testInvocationReturnValue];
    
}


/**
 schedule  不重复的timmer
 */
-(void) testTimmerWithScheduleNORepeat {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"oh");
      
    }];

    
}

/**
 schedule  重复的timmer
 */
-(void) testTimmerWithScheduleRepeat {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"oh");
        
    }];
    
    
    //[self.timer fire];
    
}

/**
 init timer
 */
-(void) testTimmerWithoutSchedule{
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1]  interval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"oh ");
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

/**
 fire一个timer
 */
-(void) testTimmerWithFire{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"oh");
        
    }];
    
    [self.timer fire];
}

/**
 GCD timmer
 */
-(void) testTimerGCD{
    //1. 创建定时器
    dispatch_source_t timer=dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    //2. schedule时间
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 15ull*NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 1ull*NSEC_PER_SEC);
    
    //3. 绑定timer的响应事件
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"wakeup");
        
        
        //调用结束timer的事件,这里可在此调用,也可写到别的地方去,把局部变量timer变成成员变量,这里写只是举例
        dispatch_source_cancel(timer);
    });
    
    //绑定timer的cancel响应事件
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"cancel");
        //dispatch_release(timer);
    });
    
    
    //4. 最重要的一步,启动timer!
    dispatch_resume(timer);
}

/**
 暂停  timer
 */
-(void) pauseTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"oh");
        
        //暂停
        [timer setFireDate:[NSDate distantFuture]];
        
       

    }];

}


- (IBAction)cancelPause:(id)sender {
    
    //继续
    [self.timer setFireDate:[NSDate date]];
    //或者:
    //[self.timer setFireDate:[NSDate distantPast]];
}

-(void) randomTimeTimer{
    
    
    self.timer =  [NSTimer timerWithTimeInterval:MAXFLOAT
                                                            target:self selector:@selector(randomTimeFireMethod)
                                                          userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];

}



-(void) randomTimeFireMethod{
    
    static int timeExecute = 0;
    NSLog(@"random call");
    
    //随机时间数组里面只放了4个元素,执行4次好了,不然用一个循环列表来做,就没有次数限制了;不然改一下timeExecute,让它逢4变1.哈哈
    if (timeExecute < 4) {
        //不定长执行
        NSTimeInterval timeInterval = [self.randomTime[timeExecute] doubleValue];
        
        timeExecute++;
        
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
        
    }
    
}




/**
 Invocation  timer
 */
-(void) testTimmer2{
    
    // 注释的也可以用
    //    NSMethodSignature * signature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    //
    //    NSInvocation * i = [NSInvocation invocationWithMethodSignature:signature];
    //    i.selector = @selector(fireMethod);
    //    i.target = self;
    
    NSMethodSignature * sig = [ViewController instanceMethodSignatureForSelector:@selector(fireMethod)];
    NSInvocation * i = [NSInvocation invocationWithMethodSignature:sig];
    
    i.selector = @selector(fireMethod);
    i.target = self;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 invocation:i repeats:NO];
    
}

/**
 Invocation 不带参数
 */
-(void) testInvocation{
    NSMethodSignature * sig = [[ViewController class] instanceMethodSignatureForSelector:@selector(fireMethod)];
    NSInvocation * i = [NSInvocation invocationWithMethodSignature:sig];
    
    i.target = self;
    i.selector = @selector(fireMethod);
    
    [i invoke];
}

/**
 Invocation 带多个参数
 */
-(void) testInvocationWithParam{
    NSMethodSignature * sig = [[ViewController class] instanceMethodSignatureForSelector:@selector(fireMethod1:str2:str3:)];
    NSInvocation * i = [NSInvocation invocationWithMethodSignature:sig];
    
    i.target = self;
    i.selector = @selector(fireMethod1:str2:str3:);
    
    //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
    NSString * param1 = @"param1";
     NSString * param2 = @"param2";
     NSString * param3 = @"param3";
    
    [i setArgument:&param1 atIndex:2];
    [i setArgument:&param2 atIndex:3];
    [i setArgument:&param3 atIndex:4];
    
    [i invoke];
}

/**
 Invocation 返回值
 */
-(void) testInvocationReturnValue{
    
    
    //创建一个函数签名，这个签名可以是任意的,但需要注意，签名函数的参数数量要和调用的一致。
    // 方法签名中保存了方法的名称/参数/返回值，协同NSInvocation来进行消息的转发
    // 方法签名一般是用来设置参数和获取返回值的, 和方法的调用没有太大的关系
    // NSInvocation中保存了方法所属的对象/方法名称/参数/返回值
    //其实NSInvocation就是将一个方法变成一个对象
    NSMethodSignature * sig = [[ViewController class] instanceMethodSignatureForSelector:@selector(addByA:b:c:)];
    NSInvocation * i = [NSInvocation invocationWithMethodSignature:sig];
    
    i.target = self;
    i.selector = @selector(addByA:b:c:);
    
    //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
    int param1 = 1;
    int param2 = 2;
    int param3 = 3;
    
    SEL cl = @selector(addByA:b:c:);
    
    //我看人家的代码还给前2个参数赋值了,这里不写也可以的
    ViewController * dd = self;
    [i setArgument:&dd atIndex:0];
    [i setArgument:&cl atIndex:1];
    
    [i setArgument:&param1 atIndex:2];
    [i setArgument:&param2 atIndex:3];
    [i setArgument:&param3 atIndex:4];
    
    //尝试设置其return值 看是否会搅乱函数的正常逻辑?
    
    [i setReturnValue:&param3];
    
    
    [i invoke];
    
    //取出其返回值查看 -- 结果是,设置返回值是没有用的
    int returnValue;
    
    [i getReturnValue:&returnValue];
    NSLog(@"returnValue:%i", returnValue);
}

#pragma mark for test

-(void) fireMethod1:(NSString *)str1 str2:(NSString *) str2 str3:(NSString *)str3 {
    NSLog(@"ho param: %@,%@,%@", str1, str2, str3);
}

-(void) fireMethod{
    NSLog(@"ho");
}

-(int) addByA:(int)a b:(int)b c:(int) c{
    NSLog(@"param:a - %i, b - %i, c - %i,", a,b,c);
    return a + b + c;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
