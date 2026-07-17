#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#define kExpireDateStr @"2099.12.31"

static NSDate *kExpireDate = nil;

static NSDate *parseExpireDate() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy.MM.dd"];
        kExpireDate = [formatter dateFromString:kExpireDateStr];
    });
    return kExpireDate;
}

static NSUInteger daysRemainingUntilExpire() {
    NSDate *expireDate = parseExpireDate();
    if (!expireDate) return 9999;
    
    NSDate *now = [NSDate date];
    NSTimeInterval diff = [expireDate timeIntervalSinceDate:now];
    NSUInteger days = (NSUInteger)(diff / (60 * 60 * 24));
    
    return days > 0 ? days : 9999;
}

static NSString *remainingDaysString() {
    return [NSString stringWithFormat:@"%lu", (unsigned long)daysRemainingUntilExpire()];
}

static NSString *remainingDaysWithPrefix() {
    return [NSString stringWithFormat:@"D-%@", remainingDaysString()];
}

@interface _TtC9Panda2Vpn8ProfileV : NSObject
@end

@interface _TtC9Panda2Vpn7MyInfoV : NSObject
@end

@interface _TtC9Panda2Vpn12UserInfoData : NSObject
@property (nonatomic, assign) BOOL isPayment;
@property (nonatomic, assign) BOOL isPaymentMyInfo;
@property (nonatomic, strong) id payInfoList;
@end

static void (*orig_ProfileV_viewSetting)(_TtC9Panda2Vpn8ProfileV *, SEL);
static void (*orig_MyInfoV_viewSetting)(_TtC9Panda2Vpn7MyInfoV *, SEL);

static id (*orig_JSONSerialization_JSONObjectWithData_options_error)(NSJSONSerialization *, SEL, NSData *, NSJSONReadingOptions, NSError **);

static void modifyLabelOnView(UIView *view) {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            NSString *text = label.text;
            
            if (text && [text isKindOfClass:[NSString class]]) {
                NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date1 = [formatter1 dateFromString:text];
                
                if (!date1) {
                    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
                    [formatter2 setDateFormat:@"yyyy.MM.dd"];
                    date1 = [formatter2 dateFromString:text];
                }
                
                if (date1) {
                    label.text = kExpireDateStr;
                } else if ([text hasPrefix:@"D-"] || [text hasPrefix:@"d-"]) {
                    label.text = remainingDaysWithPrefix();
                } else if ([text rangeOfString:@"day" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                           [text rangeOfString:@"剩余"].location != NSNotFound) {
                    label.text = [NSString stringWithFormat:@"%@ day", remainingDaysString()];
                }
            }
        }
        
        modifyLabelOnView(subview);
    }
}

static void ProfileV_viewSetting_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd) {
    orig_ProfileV_viewSetting(self, _cmd);
    
    if ([self isKindOfClass:[UIView class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            modifyLabelOnView((UIView *)self);
        });
    }
}

static void MyInfoV_viewSetting_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd) {
    orig_MyInfoV_viewSetting(self, _cmd);
    
    if ([self isKindOfClass:[UIView class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            modifyLabelOnView((UIView *)self);
        });
    }
}

static id JSONSerialization_JSONObjectWithData_hook(NSJSONSerialization *self, SEL _cmd, NSData *data, NSJSONReadingOptions opt, NSError **error) {
    id obj = orig_JSONSerialization_JSONObjectWithData_options_error(self, _cmd, data, opt, error);
    
    if (!error || !*error) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dict = [obj mutableCopy];
            
            if (dict[@"expire_datetime"]) {
                dict[@"expire_datetime"] = kExpireDateStr;
            }
            if (dict[@"isPayment"] != nil) {
                dict[@"isPayment"] = @(YES);
            }
            if (dict[@"isPaymentMyInfo"] != nil) {
                dict[@"isPaymentMyInfo"] = @(YES);
            }
            
            NSDictionary *dataDict = dict[@"data"];
            if ([dataDict isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mutableData = [dataDict mutableCopy];
                if (mutableData[@"expire_datetime"]) {
                    mutableData[@"expire_datetime"] = kExpireDateStr;
                }
                if (mutableData[@"isPayment"] != nil) {
                    mutableData[@"isPayment"] = @(YES);
                }
                if (mutableData[@"isPaymentMyInfo"] != nil) {
                    mutableData[@"isPaymentMyInfo"] = @(YES);
                }
                dict[@"data"] = mutableData;
            }
            
            return dict;
        }
    }
    
    return obj;
}

%hook _TtC9Panda2Vpn12UserInfoData

- (BOOL)isPayment {
    return YES;
}

- (BOOL)isPaymentMyInfo {
    return YES;
}

- (id)payInfoList {
    id original = %orig;
    if (!original || ([original isKindOfClass:[NSArray class]] && [original count] == 0)) {
        return [NSArray arrayWithObject:@{@"status": @"active", @"expire_datetime": kExpireDateStr}];
    }
    return original;
}

%end

__attribute__((constructor)) static void Panda2VpnCrack_init() {
    Class ProfileV = objc_getClass("_TtC9Panda2Vpn8ProfileV");
    
    if (ProfileV) {
        SEL viewSetting_sel = NSSelectorFromString(@"viewSetting");
        if (class_getInstanceMethod(ProfileV, viewSetting_sel)) {
            MSHookMessageEx(ProfileV, viewSetting_sel, (IMP)ProfileV_viewSetting_hook, (IMP*)&orig_ProfileV_viewSetting);
        }
    }
    
    Class MyInfoV = objc_getClass("_TtC9Panda2Vpn7MyInfoV");
    
    if (MyInfoV) {
        SEL viewSetting_sel = NSSelectorFromString(@"viewSetting");
        if (class_getInstanceMethod(MyInfoV, viewSetting_sel)) {
            MSHookMessageEx(MyInfoV, viewSetting_sel, (IMP)MyInfoV_viewSetting_hook, (IMP*)&orig_MyInfoV_viewSetting);
        }
    }
    
    MSHookMessageEx([NSJSONSerialization class], @selector(JSONObjectWithData:options:error:), (IMP)JSONSerialization_JSONObjectWithData_hook, (IMP*)&orig_JSONSerialization_JSONObjectWithData_options_error);
}