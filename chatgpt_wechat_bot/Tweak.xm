#include <Foundation/Foundation.h>

@interface CMessageMgr
- (void)ResendMsg:(id)arg1 MsgWrap:(id)arg2;
-(void)sendTextMsg:(NSString *)toUser fromUser:(NSString *)fromUser content:(NSString *)text;
@end

@interface CMessageWrap

@property(nonatomic) unsigned int m_uiStatus; // @synthesize m_uiStatus;
@property(retain, nonatomic) NSString *m_nsContent; // @synthesize m_nsContent;
@property(retain, nonatomic) NSString *m_nsToUsr; // @synthesize m_nsToUsr;
@property(retain, nonatomic) NSString *m_nsFromUsr; // @synthesize m_nsFromUsr;
@property(nonatomic) unsigned int m_uiScene; // @dynamic m_uiScene;

@property(nonatomic) unsigned int m_uiCreateTime; // @dynamic m_uiCreateTime;
@property(nonatomic) unsigned int m_uiMesLocalID; // @dynamic m_uiMesLocalID;

- (id)initWithMsgType:(long long)arg1 nsFromUsr:(id)arg2;
@end

%hook CMessageMgr

- (void)AsyncOnAddMsg:(NSString *)fromUser MsgWrap:(CMessageWrap* )wrap {
    %orig;

    NSString *content = wrap.m_nsContent;
	NSString *m_nsToUsr = wrap.m_nsToUsr;
	NSString *m_nsFromUsr = wrap.m_nsFromUsr;
    if([content hasPrefix:@"CGPT:"]) {
		NSString *replayMsg = [content substringFromIndex:5];
        NSLog(@"From: %@, Msg: %@", m_nsFromUsr, content);

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.henray.site:8444/chatgpt/ask"]
        cachePolicy:NSURLRequestUseProtocolCachePolicy
        timeoutInterval:360.0];
        NSDictionary *headers = @{
            @"Access-Token": @"<ACEESS TOKEN>",
            @"Content-Type": @"application/json"
        };

        [request setAllHTTPHeaderFields:headers];

        NSDictionary *payload = @{
            @"prompt": replayMsg,
            @"conversation": m_nsFromUsr
        };

        NSData *postData = [NSJSONSerialization dataWithJSONObject:payload options:kNilOptions error:nil];
        [request setHTTPBody:postData];

        [request setHTTPMethod:@"POST"];

        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"CGPT: api error, %@", error);
                [self sendTextMsg:m_nsFromUsr fromUser:m_nsToUsr content:[NSString stringWithFormat:@"出错了: %@", error]];
            } else {
                NSError *parseError = nil;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                NSLog(@"%@",responseDictionary);
                if (parseError != nil) {
                    [self sendTextMsg:m_nsFromUsr fromUser:m_nsToUsr content:@"出错了: 解析数据出错"];
                } else {
                    if ([responseDictionary[@"code"] isEqual:@(200)]) {
                        NSString * response = responseDictionary[@"response"];
                        NSLog(@"CGPT: api response, %@", response);
                        [self sendTextMsg:m_nsFromUsr fromUser:m_nsToUsr content:response];
                    } else {
                        NSString *errMsg = [NSString stringWithFormat:@"出错了: %@, %@", responseDictionary[@"code"], responseDictionary[@"msg"]];
                        [self sendTextMsg:m_nsFromUsr 
                                 fromUser:m_nsToUsr 
                                  content:errMsg];
                    }
                }
            }
        }];
        [dataTask resume];
    }
}

%new
-(void)sendTextMsg:(NSString *)toUser fromUser:(NSString *)fromUser content:(NSString *)text {
    CMessageWrap *msgWrap = [[NSClassFromString(@"CMessageWrap") alloc] initWithMsgType:1 nsFromUsr:fromUser];
    msgWrap.m_nsContent = text;
    msgWrap.m_uiMesLocalID = (int)(10000 + (arc4random() % (99999 - 10000 + 1)));;//(unsigned int)randomInt(10000, 99999);
    msgWrap.m_nsFromUsr = fromUser;
    msgWrap.m_nsToUsr = toUser;
    msgWrap.m_uiCreateTime = (int)time(NULL);
    [self ResendMsg: toUser MsgWrap:msgWrap];
    NSLog(@"CGPT: sendTextMsg %@", text);
}

%end

