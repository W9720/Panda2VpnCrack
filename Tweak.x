#import <Foundation/Foundation.h>
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

static BOOL shouldModifyKey(NSString *key) {
    NSArray *paymentKeys = @[@"isPayment", @"isPaymentMyInfo", @"is_payment", @"is_payment_my_info", @"isVip", @"is_vip", @"member", @"member_status"];
    NSArray *dateKeys = @[@"expire_datetime", @"expireDate", @"expire_date", @"endDate", @"end_date", @"expire", @"expires_at", @"expire_time", @"valid_until"];
    NSArray *dayKeys = @[@"d_day", @"dday", @"remainingDays", @"remaining_days", @"use_day", @"use_day_count", @"days_left"];
    
    for (NSString *paymentKey in paymentKeys) {
        if ([key rangeOfString:paymentKey options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    for (NSString *dateKey in dateKeys) {
        if ([key rangeOfString:dateKey options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    for (NSString *dayKey in dayKeys) {
        if ([key rangeOfString:dayKey options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

static void modifyDictionary(NSMutableDictionary *dict) {
    NSMutableArray *keysToModify = [NSMutableArray array];
    
    for (NSString *key in dict) {
        if (shouldModifyKey(key)) {
            [keysToModify addObject:key];
        }
    }
    
    for (NSString *key in keysToModify) {
        id value = dict[key];
        
        if ([key rangeOfString:@"payment" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [key rangeOfString:@"vip" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [key rangeOfString:@"member" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            if ([value isKindOfClass:[NSNumber class]]) {
                dict[key] = @(YES);
            } else if ([value isKindOfClass:[NSString class]]) {
                dict[key] = @"1";
            } else {
                dict[key] = @(YES);
            }
        } else if ([key rangeOfString:@"expire" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                   [key rangeOfString:@"endDate" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            if ([value isKindOfClass:[NSNumber class]]) {
                dict[key] = [NSNumber numberWithDouble:[parseExpireDate() timeIntervalSince1970]];
            } else {
                dict[key] = kExpireDateStr;
            }
        } else if ([key rangeOfString:@"day" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            if ([value isKindOfClass:[NSNumber class]]) {
                dict[key] = [NSNumber numberWithUnsignedInteger:daysRemainingUntilExpire()];
            } else {
                dict[key] = remainingDaysString();
            }
        }
    }
    
    for (NSString *key in dict) {
        id value = dict[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mutableValue = [value mutableCopy];
            modifyDictionary(mutableValue);
            dict[key] = mutableValue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *mutableArray = [value mutableCopy];
            for (NSUInteger i = 0; i < [mutableArray count]; i++) {
                id item = mutableArray[i];
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *mutableItem = [item mutableCopy];
                    modifyDictionary(mutableItem);
                    mutableArray[i] = mutableItem;
                }
            }
            dict[key] = mutableArray;
        }
    }
}

@interface _TtC9Panda2Vpn12UserInfoData : NSObject
@property (nonatomic, assign) BOOL isPayment;
@property (nonatomic, assign) BOOL isPaymentMyInfo;
@property (nonatomic, strong) id payInfoList;
@end

static id (*orig_JSONSerialization_JSONObjectWithData_options_error)(NSJSONSerialization *, SEL, NSData *, NSJSONReadingOptions, NSError **);

static id JSONSerialization_JSONObjectWithData_hook(NSJSONSerialization *self, SEL _cmd, NSData *data, NSJSONReadingOptions opt, NSError **error) {
    id obj = orig_JSONSerialization_JSONObjectWithData_options_error(self, _cmd, data, opt, error);
    
    if (!error || !*error) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mutableObj = [obj mutableCopy];
            modifyDictionary(mutableObj);
            return mutableObj;
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *mutableArray = [obj mutableCopy];
            for (NSUInteger i = 0; i < [mutableArray count]; i++) {
                id item = mutableArray[i];
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *mutableItem = [item mutableCopy];
                    modifyDictionary(mutableItem);
                    mutableArray[i] = mutableItem;
                }
            }
            return mutableArray;
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
    
    if ([original isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [NSMutableArray array];
        for (id item in original) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mutableItem = [item mutableCopy];
                mutableItem[@"status"] = @"active";
                mutableItem[@"expire_datetime"] = kExpireDateStr;
                [result addObject:mutableItem];
            } else {
                [result addObject:item];
            }
        }
        return result;
    }
    
    return original;
}

%end

__attribute__((constructor)) static void Panda2VpnCrack_init() {
    MSHookMessageEx([NSJSONSerialization class], @selector(JSONObjectWithData:options:error:), (IMP)JSONSerialization_JSONObjectWithData_hook, (IMP*)&orig_JSONSerialization_JSONObjectWithData_options_error);
}