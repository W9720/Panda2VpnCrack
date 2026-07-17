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
@property (nonatomic, weak) UILabel *endDateTL;
@property (nonatomic, weak) UILabel *ddayTL;
@property (nonatomic, weak) UILabel *d_dayL;
@property (nonatomic, weak) UILabel *planTL;
@property (nonatomic, weak) UILabel *planL;
@property (nonatomic, weak) UILabel *ddayL;
@end

@interface _TtC9Panda2Vpn7MyInfoV : NSObject
@property (nonatomic, weak) UILabel *endDateTL;
@property (nonatomic, weak) UILabel *endDateL;
@property (nonatomic, weak) UILabel *useDeviceL;
@end

@interface _TtC9Panda2Vpn12UserInfoData : NSObject
@property (nonatomic, assign) BOOL isPayment;
@property (nonatomic, assign) BOOL isPaymentMyInfo;
@property (nonatomic, strong) id payInfoList;
@end

static void (*orig_ProfileV_setEndDateTL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setDdayTL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setD_dayL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setPlanTL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setPlanL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_setDdayL)(_TtC9Panda2Vpn8ProfileV *, SEL, UILabel *);
static void (*orig_ProfileV_viewSetting)(_TtC9Panda2Vpn8ProfileV *, SEL);

static void (*orig_MyInfoV_setEndDateTL)(_TtC9Panda2Vpn7MyInfoV *, SEL, UILabel *);
static void (*orig_MyInfoV_setEndDateL)(_TtC9Panda2Vpn7MyInfoV *, SEL, UILabel *);
static void (*orig_MyInfoV_setUseDeviceL)(_TtC9Panda2Vpn7MyInfoV *, SEL, UILabel *);

static id (*orig_JSONSerialization_JSONObjectWithData_options_error)(NSJSONSerialization *, SEL, NSData *, NSJSONReadingOptions, NSError **);

static void ProfileV_setEndDateTL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setEndDateTL(self, _cmd, label);
    if (label) {
        label.text = kExpireDateStr;
    }
}

static void ProfileV_setDdayTL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setDdayTL(self, _cmd, label);
    if (label) {
        label.text = remainingDaysWithPrefix();
    }
}

static void ProfileV_setD_dayL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setD_dayL(self, _cmd, label);
    if (label) {
        label.text = remainingDaysWithPrefix();
    }
}

static void ProfileV_setPlanTL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setPlanTL(self, _cmd, label);
    if (label) {
        label.text = @"Premium";
    }
}

static void ProfileV_setPlanL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setPlanL(self, _cmd, label);
    if (label) {
        label.text = @"Premium";
    }
}

static void ProfileV_setDdayL_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd, UILabel *label) {
    orig_ProfileV_setDdayL(self, _cmd, label);
    if (label) {
        label.text = remainingDaysWithPrefix();
    }
}

static void ProfileV_viewSetting_hook(_TtC9Panda2Vpn8ProfileV *self, SEL _cmd) {
    orig_ProfileV_viewSetting(self, _cmd);
    
    if (self && self.endDateTL) {
        self.endDateTL.text = kExpireDateStr;
    }
    if (self && self.ddayTL) {
        self.ddayTL.text = remainingDaysWithPrefix();
    }
    if (self && self.d_dayL) {
        self.d_dayL.text = remainingDaysWithPrefix();
    }
    if (self && self.planTL) {
        self.planTL.text = @"Premium";
    }
    if (self && self.planL) {
        self.planL.text = @"Premium";
    }
    if (self && self.ddayL) {
        self.ddayL.text = remainingDaysWithPrefix();
    }
}

static void MyInfoV_setEndDateTL_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd, UILabel *label) {
    orig_MyInfoV_setEndDateTL(self, _cmd, label);
    if (label) {
        label.text = kExpireDateStr;
    }
}

static void MyInfoV_setEndDateL_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd, UILabel *label) {
    orig_MyInfoV_setEndDateL(self, _cmd, label);
    if (label) {
        label.text = kExpireDateStr;
    }
}

static void MyInfoV_setUseDeviceL_hook(_TtC9Panda2Vpn7MyInfoV *self, SEL _cmd, UILabel *label) {
    orig_MyInfoV_setUseDeviceL(self, _cmd, label);
    if (label) {
        label.text = remainingDaysWithPrefix();
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
        SEL setEndDateTL_sel = NSSelectorFromString(@"setEndDateTL:");
        SEL setDdayTL_sel = NSSelectorFromString(@"setDdayTL:");
        SEL setD_dayL_sel = NSSelectorFromString(@"setD_dayL:");
        SEL setPlanTL_sel = NSSelectorFromString(@"setPlanTL:");
        SEL setPlanL_sel = NSSelectorFromString(@"setPlanL:");
        SEL setDdayL_sel = NSSelectorFromString(@"setDdayL:");
        SEL viewSetting_sel = NSSelectorFromString(@"viewSetting");
        
        if (class_getInstanceMethod(ProfileV, setEndDateTL_sel)) {
            MSHookMessageEx(ProfileV, setEndDateTL_sel, (IMP)ProfileV_setEndDateTL_hook, (IMP*)&orig_ProfileV_setEndDateTL);
        }
        if (class_getInstanceMethod(ProfileV, setDdayTL_sel)) {
            MSHookMessageEx(ProfileV, setDdayTL_sel, (IMP)ProfileV_setDdayTL_hook, (IMP*)&orig_ProfileV_setDdayTL);
        }
        if (class_getInstanceMethod(ProfileV, setD_dayL_sel)) {
            MSHookMessageEx(ProfileV, setD_dayL_sel, (IMP)ProfileV_setD_dayL_hook, (IMP*)&orig_ProfileV_setD_dayL);
        }
        if (class_getInstanceMethod(ProfileV, setPlanTL_sel)) {
            MSHookMessageEx(ProfileV, setPlanTL_sel, (IMP)ProfileV_setPlanTL_hook, (IMP*)&orig_ProfileV_setPlanTL);
        }
        if (class_getInstanceMethod(ProfileV, setPlanL_sel)) {
            MSHookMessageEx(ProfileV, setPlanL_sel, (IMP)ProfileV_setPlanL_hook, (IMP*)&orig_ProfileV_setPlanL);
        }
        if (class_getInstanceMethod(ProfileV, setDdayL_sel)) {
            MSHookMessageEx(ProfileV, setDdayL_sel, (IMP)ProfileV_setDdayL_hook, (IMP*)&orig_ProfileV_setDdayL);
        }
        if (class_getInstanceMethod(ProfileV, viewSetting_sel)) {
            MSHookMessageEx(ProfileV, viewSetting_sel, (IMP)ProfileV_viewSetting_hook, (IMP*)&orig_ProfileV_viewSetting);
        }
    }
    
    Class MyInfoV = objc_getClass("_TtC9Panda2Vpn7MyInfoV");
    
    if (MyInfoV) {
        SEL setEndDateTL_sel = NSSelectorFromString(@"setEndDateTL:");
        SEL setEndDateL_sel = NSSelectorFromString(@"setEndDateL:");
        SEL setUseDeviceL_sel = NSSelectorFromString(@"setUseDeviceL:");
        
        if (class_getInstanceMethod(MyInfoV, setEndDateTL_sel)) {
            MSHookMessageEx(MyInfoV, setEndDateTL_sel, (IMP)MyInfoV_setEndDateTL_hook, (IMP*)&orig_MyInfoV_setEndDateTL);
        }
        if (class_getInstanceMethod(MyInfoV, setEndDateL_sel)) {
            MSHookMessageEx(MyInfoV, setEndDateL_sel, (IMP)MyInfoV_setEndDateL_hook, (IMP*)&orig_MyInfoV_setEndDateL);
        }
        if (class_getInstanceMethod(MyInfoV, setUseDeviceL_sel)) {
            MSHookMessageEx(MyInfoV, setUseDeviceL_sel, (IMP)MyInfoV_setUseDeviceL_hook, (IMP*)&orig_MyInfoV_setUseDeviceL);
        }
    }
    
    MSHookMessageEx([NSJSONSerialization class], @selector(JSONObjectWithData:options:error:), (IMP)JSONSerialization_JSONObjectWithData_hook, (IMP*)&orig_JSONSerialization_JSONObjectWithData_options_error);
}