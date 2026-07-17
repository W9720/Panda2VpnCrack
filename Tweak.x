#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#define kExpireDateStr @"2099.12.31"
#define kModifiedNickName @"喜爱民谣Crack"

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

static NSString *remainingDaysWithPrefix() {
    return [NSString stringWithFormat:@"D-%lu", (unsigned long)daysRemainingUntilExpire()];
}

@interface _TtC9Panda2Vpn8ProfileV : NSObject
@end

@interface _TtC9Panda2Vpn7MyInfoV : NSObject
@end

@interface _TtC9Panda2Vpn12UserInfoData : NSObject
@end

static id (*orig_JSONSerialization_JSONObjectWithData_options_error)(NSJSONSerialization *, SEL, NSData *, NSJSONReadingOptions, NSError **);

static BOOL isDateString(NSString *text) {
    if (!text || ![text isKindOfClass:[NSString class]]) return NO;
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if ([formatter1 dateFromString:text]) return YES;
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd"];
    if ([formatter2 dateFromString:text]) return YES;
    
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"yyyy.MM.dd"];
    if ([formatter3 dateFromString:text]) return YES;
    
    return NO;
}

static void modifyLabelOnView(UIView *view) {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            NSString *text = label.text;
            
            if (text && [text isKindOfClass:[NSString class]]) {
                if (isDateString(text)) {
                    label.text = kExpireDateStr;
                } else if ([text hasPrefix:@"D-"] || [text hasPrefix:@"d-"]) {
                    label.text = remainingDaysWithPrefix();
                } else if ([text isEqualToString:@"喜爱民谣"]) {
                    label.text = kModifiedNickName;
                }
            }
        }
        
        modifyLabelOnView(subview);
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

%hook _TtC9Panda2Vpn8ProfileV

- (void)viewSetting {
    %orig;
    
    if ([self isKindOfClass:[UIView class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            modifyLabelOnView((UIView *)self);
        });
    }
}

%end

%hook _TtC9Panda2Vpn7MyInfoV

- (void)viewSetting {
    %orig;
    
    if ([self isKindOfClass:[UIView class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            modifyLabelOnView((UIView *)self);
        });
    }
}

%end

__attribute__((constructor)) static void Panda2VpnCrack_init() {
    MSHookMessageEx([NSJSONSerialization class], @selector(JSONObjectWithData:options:error:), (IMP)JSONSerialization_JSONObjectWithData_hook, (IMP*)&orig_JSONSerialization_JSONObjectWithData_options_error);
}