//
// Wire
// Copyright (C) 2024 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

@import Foundation;
@import WireDataModel;

#import "ZMBaseManagedObjectTest.h"

@interface ZMSearchUserTests : ZMBaseManagedObjectTest <ZMUserObserving>
@property (nonatomic) NSMutableArray *userNotifications;
@end

@implementation ZMSearchUserTests

- (void)setUp {
    [super setUp];

    self.userNotifications = [NSMutableArray array];
}

- (void)tearDown {
    self.userNotifications = nil;
    [super tearDown];
}

- (void)userDidChange:(UserChangeInfo *)note
{
    [self.userNotifications addObject:note];
}

- (void)testThatItComparesEqualBasedOnRemoteID;
{
    // given
    NSUUID *remoteIDA = [NSUUID createUUID];
    NSUUID *remoteIDB = [NSUUID createUUID];

    ZMSearchUser *user1 = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                   name:@"A"
                                                                 handle:@"a"
                                                            accentColor:ZMAccentColor.green
                                                       remoteIdentifier:remoteIDA
                                                                 domain:nil
                                                         teamIdentifier:nil
                                                                   user:nil
                                                                contact:nil
                                                       searchUsersCache:nil];

    // (1)
    ZMSearchUser *user2 = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                   name:@"B"
                                                                 handle:@"b"
                                                            accentColor:ZMAccentColor.purple
                                                       remoteIdentifier:remoteIDA
                                                                 domain:nil
                                                         teamIdentifier:nil
                                                                   user:nil
                                                                contact:nil
                                                       searchUsersCache:nil];

    XCTAssertEqualObjects(user1, user2);
    XCTAssertEqual(user1.hash, user2.hash);
    
    // (2)
    ZMSearchUser *user3 = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                   name:@"A"
                                                                 handle:@"b"
                                                            accentColor:ZMAccentColor.green
                                                       remoteIdentifier:remoteIDB
                                                                 domain:nil
                                                         teamIdentifier:nil
                                                                   user:nil
                                                                contact:nil
                                                       searchUsersCache:nil];

    XCTAssertNotEqualObjects(user1, user3);
}

- (void)testThatItComparesEqualBasedOnContactWhenRemoteIDIsNil
{
    // Given
    ZMAddressBookContact *contact1 = [[ZMAddressBookContact alloc] init];
    contact1.firstName = @"A";
    
    ZMAddressBookContact *contact2  =[[ZMAddressBookContact alloc] init];
    contact2.firstName = @"B";
    
    ZMSearchUser *user1 = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                contact:contact1
                                                                   user:nil
                                                       searchUsersCache:nil];
    ZMSearchUser *user2 = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack 
                                                                contact:contact1
                                                                   user:nil
                                                       searchUsersCache:nil];
    ZMSearchUser *user3 = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                contact:contact2 
                                                                   user:nil
                                                       searchUsersCache:nil];

    // Then
    XCTAssertEqualObjects(user1, user2);
    XCTAssertNotEqualObjects(user1, user3);
}

- (void)testThatItHasAllDataItWasInitializedWith
{
    // given
    NSString *name = @"John Doe";
    NSString *handle = @"doe";
    NSUUID *remoteID = [NSUUID createUUID];
    
    // when
    ZMSearchUser *searchUser = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                        name:name
                                                                      handle:handle
                                                                 accentColor:ZMAccentColor.green
                                                            remoteIdentifier:remoteID
                                                                      domain:nil
                                                              teamIdentifier:nil
                                                                        user:nil
                                                                     contact:nil
                                                            searchUsersCache:nil];

    
    // then
    XCTAssertEqualObjects(searchUser.name, @"John Doe");
    XCTAssertEqual(searchUser.zmAccentColor, ZMAccentColor.green);
    XCTAssertEqual(searchUser.isConnected, NO);
    XCTAssertNil(searchUser.completeImageData);
    XCTAssertNil(searchUser.previewImageData);
    XCTAssertNil(searchUser.user);
    XCTAssertEqualObjects(searchUser.handle, handle);
}


- (void)testThatItUsesDataFromAUserIfItHasOne
{
    // given
    ZMUser *user = [ZMUser insertNewObjectInManagedObjectContext:self.uiMOC];
    user.name = @"Actual name";
    user.handle = @"my_handle";
    user.zmAccentColor = ZMAccentColor.red;
    user.connection = [ZMConnection insertNewObjectInManagedObjectContext:self.uiMOC];
    user.connection.status = ZMConnectionStatusAccepted;
    user.remoteIdentifier = [NSUUID createUUID];
    [user setImageData:[@"image medium data" dataUsingEncoding:NSUTF8StringEncoding] size:ProfileImageSizeComplete];
    [user setImageData:[@"image small profile data" dataUsingEncoding:NSUTF8StringEncoding] size:ProfileImageSizePreview];
    [self.uiMOC saveOrRollback];
    
   
    
    // when
    ZMSearchUser *searchUser = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                        name:@"Wrong name"
                                                                      handle:@"not_my_handle"
                                                                 accentColor:ZMAccentColor.green
                                                            remoteIdentifier:[NSUUID createUUID]
                                                                      domain:nil
                                                              teamIdentifier:nil
                                                                        user:user
                                                                     contact:nil
                                                            searchUsersCache:nil];

    // then
    XCTAssertEqualObjects(searchUser.name, user.name);
    XCTAssertEqualObjects(searchUser.handle, user.handle);
    XCTAssertEqualObjects(searchUser.name, user.name);
    XCTAssertEqual(searchUser.zmAccentColor, user.zmAccentColor);
    XCTAssertEqual(searchUser.isConnected, user.isConnected);
    XCTAssertEqualObjects(searchUser.completeImageData, user.completeImageData);
    XCTAssertEqualObjects(searchUser.previewImageData, user.previewImageData);
    XCTAssertEqual(searchUser.user, user);
}


// MARK: - Connections


- (void)testThatItCanBeConnectedIfItIsNotAlreadyConnected
{
    // given
    ZMSearchUser *searchUser = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                        name:@"Hans"
                                                                      handle:@"hans"
                                                                 accentColor:ZMAccentColor.green
                                                            remoteIdentifier:NSUUID.createUUID
                                                                      domain:nil
                                                              teamIdentifier:nil
                                                                        user:nil
                                                                     contact:nil
                                                            searchUsersCache:nil];

    
    // then
    XCTAssertTrue(searchUser.canBeConnected);
}


- (void)testThatItCanNotBeConnectedIfItHasNoRemoteIdentifier
{
    // given
    ZMSearchUser *searchUser = [[ZMSearchUser alloc] initWithContextProvider:self.coreDataStack
                                                                        name:@"Hans"
                                                                      handle:@"hans"
                                                                 accentColor:ZMAccentColor.green
                                                            remoteIdentifier:nil
                                                                      domain:nil
                                                              teamIdentifier:nil
                                                                        user:nil
                                                                     contact:nil
                                                            searchUsersCache:nil];

    // then
    XCTAssertFalse(searchUser.canBeConnected);
}

@end
