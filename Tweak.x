#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>

#define kExpireDateStr @"2099.12.31"
#define kPlanStatus @"Premium"

static NSDate *kExpireDate = nil;
static NSString *kAPIHost = @"staff20231205.com";

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

static NSString *timestampString() {
    NSDate *expireDate = parseExpireDate();
    if (!expireDate) return @"4102358400";
    
    return [NSString stringWithFormat:@"%.0f", [expireDate timeIntervalSince1970]];
}

static BOOL isTargetAPI(NSString *urlStr) {
    return [urlStr rangeOfString:kAPIHost options:NSCaseInsensitiveSearch].location != NSNotFound;
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

@interface _TtC9Panda2Vpn8ProfileV : NSObject
@property (nonatomic, weak) UILabel *endDateL;
@property (nonatomic, weak) UILabel *ddayL;
@property (nonatomic, weak) UILabel *planL;
@end

@interface _TtC9Panda2Vpn7MyInfoV : NSObject
@property (nonatomic, weak) UILabel *endDateL;
@property (nonatomic, weak) UILabel *useL;
@property (nonatomic, weak) UILabel *useTL;
@end

@interface _TtC9Panda2Vpn12UserInfoData : NSObject
@property (nonatomic, assign) BOOL isPayment;
@property (nonatomic, assign) BOOL isPaymentMyInfo;
@property (nonatomic, strong) id payInfoList;
@property (nonatomic, strong) id myInfoData;
@end

@interface _TtC9Panda2Vpn3API : NSObject
@end

static void (*orig_ProfileV_setEndDateL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setDdayL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setPlanL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_MyInfoV_setEndDateL)(_TtC9Panda2Vpn7MyInfoV *, SEL, UILabel *);
static void (*orig_MyInfoV_setUseL)(_TtC9Panda2Vpn7MyInfoV *, SEL, UILabel *);
static void (*orig_MyInfoV_setUseTL)(_TtC9Panda2Vpn7MyInfoV *, SEL, UILabel *);
static void (*orig_ProfileV_viewSetting)(_TtC9Panda2Vpn8ProfileV *, SEL);

static id (*orig_JSONSerialization_dataWithJSONObject_options_error)(NSJSONSerialization *, SEL, id, NSJSONWritingOptions, NSError **);
static id (*orig_JSONSerialization_JSONObjectWithData_options_error)(NSJSONSerialization *, SEL, NSData *, NSJSONReadingOptions, NSError **);
static void (*orig_NSUserDefaults_setObject_forKey)(NSUserDefaults *, SEL, id, NSString *);
static id (*orig_NSUserDefaults_objectForKey)(NSUserDefaults *, SEL, NSString *);

static void ProfileV_setEndDateL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setEndDateL(self, _cmd, label);
    if (label) {
        label.text = kExpireDateStr;
    }
}

static void ProfileV_setDdayL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setDdayL(self, _cmd, label);
    if (label) {
        label.text = remainingDaysString();
    }
}

static void ProfileV_setPlanL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setPlanL(self, _cmd, label);
    if (label) {
        label.text = kPlanStatus;
    }
}

static void MyInfoV_setEndDateL_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd, UILabel *label) {
    orig_MyInfoV_setEndDateL(self, _cmd, label);
    if (label) {
        label.text = kExpireDateStr;
    }
}

static void MyInfoV_setUseL_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd, UILabel *label) {
    orig_MyInfoV_setUseL(self, _cmd, label);
    if (label) {
        label.text = [NSString stringWithFormat:@"%@ day", remainingDaysString()];
    }
}

static void MyInfoV_setUseTL_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd, UILabel *label) {
    orig_MyInfoV_setUseTL(self, _cmd, label);
    if (label) {
        label.text = [NSString stringWithFormat:@"%@ day", remainingDaysString()];
    }
}

static void ProfileV_viewSetting_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd) {
    orig_ProfileV_viewSetting(self, _cmd);
    
    if (self && self.endDateL) {
        self.endDateL.text = kExpireDateStr;
    }
    if (self && self.ddayL) {
        self.ddayL.text = remainingDaysString();
    }
    if (self && self.planL) {
        self.planL.text = kPlanStatus;
    }
}

static id JSONSerialization_dataWithJSONObject_hook(NSJSONSerialization *self, SEL _cmd, id obj, NSJSONWritingOptions opt, NSError **error) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableObj = [obj mutableCopy];
        modifyDictionary(mutableObj);
        obj = mutableObj;
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
        obj = mutableArray;
    }
    
    return orig_JSONSerialization_dataWithJSONObject_options_error(self, _cmd, obj, opt, error);
}

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

static void NSUserDefaults_setObject_hook(NSUserDefaults *self, SEL _cmd, id value, NSString *defaultName) {
    if ([value isKindOfClass:[NSString class]]) {
        if ([defaultName rangeOfString:@"payment" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [defaultName rangeOfString:@"isPayment" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            value = @"1";
        }
        if ([defaultName rangeOfString:@"expire" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [defaultName rangeOfString:@"endDate" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            value = kExpireDateStr;
        }
        if ([defaultName rangeOfString:@"day" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [defaultName rangeOfString:@"dday" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            value = remainingDaysString();
        }
    }
    
    orig_NSUserDefaults_setObject_forKey(self, _cmd, value, defaultName);
}

static id NSUserDefaults_objectForKey_hook(NSUserDefaults *self, SEL _cmd, NSString *defaultName) {
    id value = orig_NSUserDefaults_objectForKey(self, _cmd, defaultName);
    
    if ([defaultName rangeOfString:@"payment" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [defaultName rangeOfString:@"isPayment" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return @"1";
    }
    if ([defaultName rangeOfString:@"expire" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [defaultName rangeOfString:@"endDate" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return kExpireDateStr;
    }
    if ([defaultName rangeOfString:@"day" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [defaultName rangeOfString:@"dday" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return remainingDaysString();
    }
    
    return value;
}

static void clearOriginalCache() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults dictionaryRepresentation];
    
    for (NSString *key in dict) {
        if ([key rangeOfString:@"payment" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [key rangeOfString:@"isPayment" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [key rangeOfString:@"expire" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [key rangeOfString:@"endDate" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [key rangeOfString:@"day" options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [key rangeOfString:@"dday" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [defaults removeObjectForKey:key];
        }
    }
    
    [defaults synchronize];
}

static void persistCrackedData() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"1" forKey:@"isPayment"];
    [defaults setObject:@"1" forKey:@"isPaymentMyInfo"];
    [defaults setObject:kExpireDateStr forKey:@"expire_datetime"];
    [defaults setObject:kExpireDateStr forKey:@"expireDate"];
    [defaults setObject:kExpireDateStr forKey:@"endDate"];
    [defaults setObject:remainingDaysString() forKey:@"d_day"];
    [defaults setObject:remainingDaysString() forKey:@"dday"];
    [defaults setObject:remainingDaysString() forKey:@"remainingDays"];
    [defaults synchronize];
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
    clearOriginalCache();
    persistCrackedData();
    
    Class ProfileV = objc_getClass("_TtC9Panda2Vpn8ProfileV");
    Class MyInfoV = objc_getClass("_TtC9Panda2Vpn7MyInfoV");
    
    if (ProfileV) {
        SEL setEndDateL_sel = NSSelectorFromString(@"setEndDateL:");
        SEL setDdayL_sel = NSSelectorFromString(@"setDdayL:");
        SEL setPlanL_sel = NSSelectorFromString(@"setPlanL:");
        SEL viewSetting_sel = NSSelectorFromString(@"viewSetting");
        
        if (class_getInstanceMethod(ProfileV, setEndDateL_sel)) {
            MSHookMessageEx(ProfileV, setEndDateL_sel, (IMP)ProfileV_setEndDateL_hook, (IMP*)&orig_ProfileV_setEndDateL);
        }
        
        if (class_getInstanceMethod(ProfileV, setDdayL_sel)) {
            MSHookMessageEx(ProfileV, setDdayL_sel, (IMP)ProfileV_setDdayL_hook, (IMP*)&orig_ProfileV_setDdayL);
        }
        
        if (class_getInstanceMethod(ProfileV, setPlanL_sel)) {
            MSHookMessageEx(ProfileV, setPlanL_sel, (IMP)ProfileV_setPlanL_hook, (IMP*)&orig_ProfileV_setPlanL);
        }
        
        if (class_getInstanceMethod(ProfileV, viewSetting_sel)) {
            MSHookMessageEx(ProfileV, viewSetting_sel, (IMP)ProfileV_viewSetting_hook, (IMP*)&orig_ProfileV_viewSetting);
        }
    }
    
    if (MyInfoV) {
        SEL setEndDateL_sel = NSSelectorFromString(@"setEndDateL:");
        SEL setUseL_sel = NSSelectorFromString(@"setUseL:");
        SEL setUseTL_sel = NSSelectorFromString(@"setUseTL:");
        
        if (class_getInstanceMethod(MyInfoV, setEndDateL_sel)) {
            MSHookMessageEx(MyInfoV, setEndDateL_sel, (IMP)MyInfoV_setEndDateL_hook, (IMP*)&orig_MyInfoV_setEndDateL);
        }
        
        if (class_getInstanceMethod(MyInfoV, setUseL_sel)) {
            MSHookMessageEx(MyInfoV, setUseL_sel, (IMP)MyInfoV_setUseL_hook, (IMP*)&orig_MyInfoV_setUseL);
        }
        
        if (class_getInstanceMethod(MyInfoV, setUseTL_sel)) {
            MSHookMessageEx(MyInfoV, setUseTL_sel, (IMP)MyInfoV_setUseTL_hook, (IMP*)&orig_MyInfoV_setUseTL);
        }
    }
    
    MSHookMessageEx([NSJSONSerialization class], @selector(dataWithJSONObject:options:error:), (IMP)JSONSerialization_dataWithJSONObject_hook, (IMP*)&orig_JSONSerialization_dataWithJSONObject_options_error);
    
    MSHookMessageEx([NSJSONSerialization class], @selector(JSONObjectWithData:options:error:), (IMP)JSONSerialization_JSONObjectWithData_hook, (IMP*)&orig_JSONSerialization_JSONObjectWithData_options_error);
    
    MSHookMessageEx([NSUserDefaults class], @selector(setObject:forKey:), (IMP)NSUserDefaults_setObject_hook, (IMP*)&orig_NSUserDefaults_setObject_forKey);
    
    MSHookMessageEx([NSUserDefaults class], @selector(objectForKey:), (IMP)NSUserDefaults_objectForKey_hook, (IMP*)&orig_NSUserDefaults_objectForKey);
}