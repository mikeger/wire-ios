// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

// swiftlint:disable superfluous_disable_command
// swiftlint:disable vertical_whitespace
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif


@testable import WireSyncEngine





















public class MockCertificateRevocationListsChecking: CertificateRevocationListsChecking {

    // MARK: - Life cycle

    public init() {}


    // MARK: - checkNewCRLs

    public var checkNewCRLsFrom_Invocations: [CRLsDistributionPoints] = []
    public var checkNewCRLsFrom_MockMethod: ((CRLsDistributionPoints) async -> Void)?

    public func checkNewCRLs(from distributionPoints: CRLsDistributionPoints) async {
        checkNewCRLsFrom_Invocations.append(distributionPoints)

        guard let mock = checkNewCRLsFrom_MockMethod else {
            fatalError("no mock for `checkNewCRLsFrom`")
        }

        await mock(distributionPoints)
    }

    // MARK: - checkExpiredCRLs

    public var checkExpiredCRLs_Invocations: [Void] = []
    public var checkExpiredCRLs_MockMethod: (() async -> Void)?

    public func checkExpiredCRLs() async {
        checkExpiredCRLs_Invocations.append(())

        guard let mock = checkExpiredCRLs_MockMethod else {
            fatalError("no mock for `checkExpiredCRLs`")
        }

        await mock()
    }

}

public class MockCheckOneOnOneConversationIsReadyUseCaseProtocol: CheckOneOnOneConversationIsReadyUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invokeUserID_Invocations: [QualifiedID] = []
    public var invokeUserID_MockError: Error?
    public var invokeUserID_MockMethod: ((QualifiedID) async throws -> Bool)?
    public var invokeUserID_MockValue: Bool?

    public func invoke(userID: QualifiedID) async throws -> Bool {
        invokeUserID_Invocations.append(userID)

        if let error = invokeUserID_MockError {
            throw error
        }

        if let mock = invokeUserID_MockMethod {
            return try await mock(userID)
        } else if let mock = invokeUserID_MockValue {
            return mock
        } else {
            fatalError("no mock for `invokeUserID`")
        }
    }

}

public class MockE2EIdentityCertificateUpdateStatusUseCaseProtocol: E2EIdentityCertificateUpdateStatusUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invoke_Invocations: [Void] = []
    public var invoke_MockError: Error?
    public var invoke_MockMethod: (() async throws -> E2EIdentityCertificateUpdateStatus)?
    public var invoke_MockValue: E2EIdentityCertificateUpdateStatus?

    public func invoke() async throws -> E2EIdentityCertificateUpdateStatus {
        invoke_Invocations.append(())

        if let error = invoke_MockError {
            throw error
        }

        if let mock = invoke_MockMethod {
            return try await mock()
        } else if let mock = invoke_MockValue {
            return mock
        } else {
            fatalError("no mock for `invoke`")
        }
    }

}

public class MockGetE2eIdentityCertificatesUseCaseProtocol: GetE2eIdentityCertificatesUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invokeMlsGroupIdClientIds_Invocations: [(mlsGroupId: MLSGroupID, clientIds: [MLSClientID])] = []
    public var invokeMlsGroupIdClientIds_MockError: Error?
    public var invokeMlsGroupIdClientIds_MockMethod: ((MLSGroupID, [MLSClientID]) async throws -> [E2eIdentityCertificate])?
    public var invokeMlsGroupIdClientIds_MockValue: [E2eIdentityCertificate]?

    public func invoke(mlsGroupId: MLSGroupID, clientIds: [MLSClientID]) async throws -> [E2eIdentityCertificate] {
        invokeMlsGroupIdClientIds_Invocations.append((mlsGroupId: mlsGroupId, clientIds: clientIds))

        if let error = invokeMlsGroupIdClientIds_MockError {
            throw error
        }

        if let mock = invokeMlsGroupIdClientIds_MockMethod {
            return try await mock(mlsGroupId, clientIds)
        } else if let mock = invokeMlsGroupIdClientIds_MockValue {
            return mock
        } else {
            fatalError("no mock for `invokeMlsGroupIdClientIds`")
        }
    }

}

public class MockGetIsE2EIdentityEnabledUseCaseProtocol: GetIsE2EIdentityEnabledUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invoke_Invocations: [Void] = []
    public var invoke_MockError: Error?
    public var invoke_MockMethod: (() async throws -> Bool)?
    public var invoke_MockValue: Bool?

    public func invoke() async throws -> Bool {
        invoke_Invocations.append(())

        if let error = invoke_MockError {
            throw error
        }

        if let mock = invoke_MockMethod {
            return try await mock()
        } else if let mock = invoke_MockValue {
            return mock
        } else {
            fatalError("no mock for `invoke`")
        }
    }

}

public class MockGetMLSFeatureUseCaseProtocol: GetMLSFeatureUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invoke_Invocations: [Void] = []
    public var invoke_MockMethod: (() -> Feature.MLS)?
    public var invoke_MockValue: Feature.MLS?

    public func invoke() -> Feature.MLS {
        invoke_Invocations.append(())

        if let mock = invoke_MockMethod {
            return mock()
        } else if let mock = invoke_MockValue {
            return mock
        } else {
            fatalError("no mock for `invoke`")
        }
    }

}

public class MockGetUserClientFingerprintUseCaseProtocol: GetUserClientFingerprintUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invokeUserClient_Invocations: [UserClient] = []
    public var invokeUserClient_MockMethod: ((UserClient) async -> Data?)?
    public var invokeUserClient_MockValue: Data??

    public func invoke(userClient: UserClient) async -> Data? {
        invokeUserClient_Invocations.append(userClient)

        if let mock = invokeUserClient_MockMethod {
            return await mock(userClient)
        } else if let mock = invokeUserClient_MockValue {
            return mock
        } else {
            fatalError("no mock for `invokeUserClient`")
        }
    }

}

public class MockIsE2EICertificateEnrollmentRequiredProtocol: IsE2EICertificateEnrollmentRequiredProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invoke_Invocations: [Void] = []
    public var invoke_MockError: Error?
    public var invoke_MockMethod: (() async throws -> Bool)?
    public var invoke_MockValue: Bool?

    public func invoke() async throws -> Bool {
        invoke_Invocations.append(())

        if let error = invoke_MockError {
            throw error
        }

        if let mock = invoke_MockMethod {
            return try await mock()
        } else if let mock = invoke_MockValue {
            return mock
        } else {
            fatalError("no mock for `invoke`")
        }
    }

}

public class MockPasteboard: Pasteboard {

    // MARK: - Life cycle

    public init() {}

    // MARK: - text

    public var text: String?


}

class MockRecurringActionServiceInterface: RecurringActionServiceInterface {

    // MARK: - Life cycle



    // MARK: - performActionsIfNeeded

    var performActionsIfNeeded_Invocations: [Void] = []
    var performActionsIfNeeded_MockMethod: (() -> Void)?

    func performActionsIfNeeded() {
        performActionsIfNeeded_Invocations.append(())

        guard let mock = performActionsIfNeeded_MockMethod else {
            fatalError("no mock for `performActionsIfNeeded`")
        }

        mock()
    }

    // MARK: - registerAction

    var registerAction_Invocations: [RecurringAction] = []
    var registerAction_MockMethod: ((RecurringAction) -> Void)?

    func registerAction(_ action: RecurringAction) {
        registerAction_Invocations.append(action)

        guard let mock = registerAction_MockMethod else {
            fatalError("no mock for `registerAction`")
        }

        mock(action)
    }

    // MARK: - forcePerformAction

    var forcePerformActionId_Invocations: [String] = []
    var forcePerformActionId_MockMethod: ((String) -> Void)?

    func forcePerformAction(id: String) {
        forcePerformActionId_Invocations.append(id)

        guard let mock = forcePerformActionId_MockMethod else {
            fatalError("no mock for `forcePerformActionId`")
        }

        mock(id)
    }

    // MARK: - removeAction

    var removeActionId_Invocations: [String] = []
    var removeActionId_MockMethod: ((String) -> Void)?

    func removeAction(id: String) {
        removeActionId_Invocations.append(id)

        guard let mock = removeActionId_MockMethod else {
            fatalError("no mock for `removeActionId`")
        }

        mock(id)
    }

}

public class MockRemoveUserClientUseCaseProtocol: RemoveUserClientUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invokeClientIdCredentials_Invocations: [(clientId: String, credentials: EmailCredentials?)] = []
    public var invokeClientIdCredentials_MockError: Error?
    public var invokeClientIdCredentials_MockMethod: ((String, EmailCredentials?) async throws -> Void)?

    public func invoke(clientId: String, credentials: EmailCredentials?) async throws {
        invokeClientIdCredentials_Invocations.append((clientId: clientId, credentials: credentials))

        if let error = invokeClientIdCredentials_MockError {
            throw error
        }

        guard let mock = invokeClientIdCredentials_MockMethod else {
            fatalError("no mock for `invokeClientIdCredentials`")
        }

        try await mock(clientId, credentials)
    }

}

public class MockResolveOneOnOneConversationsUseCaseProtocol: ResolveOneOnOneConversationsUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invoke_Invocations: [Void] = []
    public var invoke_MockError: Error?
    public var invoke_MockMethod: (() async throws -> Void)?

    public func invoke() async throws {
        invoke_Invocations.append(())

        if let error = invoke_MockError {
            throw error
        }

        guard let mock = invoke_MockMethod else {
            fatalError("no mock for `invoke`")
        }

        try await mock()
    }

}

public class MockSelfClientCertificateProviderProtocol: SelfClientCertificateProviderProtocol {

    // MARK: - Life cycle

    public init() {}

    // MARK: - hasCertificate

    public var hasCertificateCallsCount = 0
    public var hasCertificateCalled: Bool {
        return hasCertificateCallsCount > 0
    }

    public var hasCertificate: Bool {
        get async {
            hasCertificateCallsCount += 1
            if let hasCertificateClosure = hasCertificateClosure {
                return await hasCertificateClosure()
            } else {
                return underlyingHasCertificate
            }
        }
    }
    public var underlyingHasCertificate: Bool!
    public var hasCertificateClosure: (() async -> Bool)?


    // MARK: - getCertificate

    public var getCertificate_Invocations: [Void] = []
    public var getCertificate_MockError: Error?
    public var getCertificate_MockMethod: (() async throws -> E2eIdentityCertificate?)?
    public var getCertificate_MockValue: E2eIdentityCertificate??

    public func getCertificate() async throws -> E2eIdentityCertificate? {
        getCertificate_Invocations.append(())

        if let error = getCertificate_MockError {
            throw error
        }

        if let mock = getCertificate_MockMethod {
            return try await mock()
        } else if let mock = getCertificate_MockValue {
            return mock
        } else {
            fatalError("no mock for `getCertificate`")
        }
    }

}

public class MockServerConnection: ServerConnection {

    // MARK: - Life cycle

    public init() {}

    // MARK: - isMobileConnection

    public var isMobileConnection: Bool {
        get { return underlyingIsMobileConnection }
        set(value) { underlyingIsMobileConnection = value }
    }

    public var underlyingIsMobileConnection: Bool!

    // MARK: - isOffline

    public var isOffline: Bool {
        get { return underlyingIsOffline }
        set(value) { underlyingIsOffline = value }
    }

    public var underlyingIsOffline: Bool!


}

public class MockSessionManagerDelegate: SessionManagerDelegate {

    // MARK: - Life cycle

    public init() {}

    // MARK: - isInAuthenticatedAppState

    public var isInAuthenticatedAppState: Bool {
        get { return underlyingIsInAuthenticatedAppState }
        set(value) { underlyingIsInAuthenticatedAppState = value }
    }

    public var underlyingIsInAuthenticatedAppState: Bool!

    // MARK: - isInUnathenticatedAppState

    public var isInUnathenticatedAppState: Bool {
        get { return underlyingIsInUnathenticatedAppState }
        set(value) { underlyingIsInUnathenticatedAppState = value }
    }

    public var underlyingIsInUnathenticatedAppState: Bool!


    // MARK: - sessionManagerDidFailToLogin

    public var sessionManagerDidFailToLoginError_Invocations: [Error?] = []
    public var sessionManagerDidFailToLoginError_MockMethod: ((Error?) -> Void)?

    public func sessionManagerDidFailToLogin(error: Error?) {
        sessionManagerDidFailToLoginError_Invocations.append(error)

        guard let mock = sessionManagerDidFailToLoginError_MockMethod else {
            fatalError("no mock for `sessionManagerDidFailToLoginError`")
        }

        mock(error)
    }

    // MARK: - sessionManagerWillLogout

    public var sessionManagerWillLogoutErrorUserSessionCanBeTornDown_Invocations: [(error: Error?, userSessionCanBeTornDown: (() -> Void)?)] = []
    public var sessionManagerWillLogoutErrorUserSessionCanBeTornDown_MockMethod: ((Error?, (() -> Void)?) -> Void)?

    public func sessionManagerWillLogout(error: Error?, userSessionCanBeTornDown: (() -> Void)?) {
        sessionManagerWillLogoutErrorUserSessionCanBeTornDown_Invocations.append((error: error, userSessionCanBeTornDown: userSessionCanBeTornDown))

        guard let mock = sessionManagerWillLogoutErrorUserSessionCanBeTornDown_MockMethod else {
            fatalError("no mock for `sessionManagerWillLogoutErrorUserSessionCanBeTornDown`")
        }

        mock(error, userSessionCanBeTornDown)
    }

    // MARK: - sessionManagerWillOpenAccount

    public var sessionManagerWillOpenAccountFromUserSessionCanBeTornDown_Invocations: [(account: Account, selectedAccount: Account?, userSessionCanBeTornDown: () -> Void)] = []
    public var sessionManagerWillOpenAccountFromUserSessionCanBeTornDown_MockMethod: ((Account, Account?, @escaping () -> Void) -> Void)?

    public func sessionManagerWillOpenAccount(_ account: Account, from selectedAccount: Account?, userSessionCanBeTornDown: @escaping () -> Void) {
        sessionManagerWillOpenAccountFromUserSessionCanBeTornDown_Invocations.append((account: account, selectedAccount: selectedAccount, userSessionCanBeTornDown: userSessionCanBeTornDown))

        guard let mock = sessionManagerWillOpenAccountFromUserSessionCanBeTornDown_MockMethod else {
            fatalError("no mock for `sessionManagerWillOpenAccountFromUserSessionCanBeTornDown`")
        }

        mock(account, selectedAccount, userSessionCanBeTornDown)
    }

    // MARK: - sessionManagerWillMigrateAccount

    public var sessionManagerWillMigrateAccountUserSessionCanBeTornDown_Invocations: [() -> Void] = []
    public var sessionManagerWillMigrateAccountUserSessionCanBeTornDown_MockMethod: ((@escaping () -> Void) -> Void)?

    public func sessionManagerWillMigrateAccount(userSessionCanBeTornDown: @escaping () -> Void) {
        sessionManagerWillMigrateAccountUserSessionCanBeTornDown_Invocations.append(userSessionCanBeTornDown)

        guard let mock = sessionManagerWillMigrateAccountUserSessionCanBeTornDown_MockMethod else {
            fatalError("no mock for `sessionManagerWillMigrateAccountUserSessionCanBeTornDown`")
        }

        mock(userSessionCanBeTornDown)
    }

    // MARK: - sessionManagerDidFailToLoadDatabase

    public var sessionManagerDidFailToLoadDatabaseError_Invocations: [Error] = []
    public var sessionManagerDidFailToLoadDatabaseError_MockMethod: ((Error) -> Void)?

    public func sessionManagerDidFailToLoadDatabase(error: Error) {
        sessionManagerDidFailToLoadDatabaseError_Invocations.append(error)

        guard let mock = sessionManagerDidFailToLoadDatabaseError_MockMethod else {
            fatalError("no mock for `sessionManagerDidFailToLoadDatabaseError`")
        }

        mock(error)
    }

    // MARK: - sessionManagerDidBlacklistCurrentVersion

    public var sessionManagerDidBlacklistCurrentVersionReason_Invocations: [BlacklistReason] = []
    public var sessionManagerDidBlacklistCurrentVersionReason_MockMethod: ((BlacklistReason) -> Void)?

    public func sessionManagerDidBlacklistCurrentVersion(reason: BlacklistReason) {
        sessionManagerDidBlacklistCurrentVersionReason_Invocations.append(reason)

        guard let mock = sessionManagerDidBlacklistCurrentVersionReason_MockMethod else {
            fatalError("no mock for `sessionManagerDidBlacklistCurrentVersionReason`")
        }

        mock(reason)
    }

    // MARK: - sessionManagerDidBlacklistJailbrokenDevice

    public var sessionManagerDidBlacklistJailbrokenDevice_Invocations: [Void] = []
    public var sessionManagerDidBlacklistJailbrokenDevice_MockMethod: (() -> Void)?

    public func sessionManagerDidBlacklistJailbrokenDevice() {
        sessionManagerDidBlacklistJailbrokenDevice_Invocations.append(())

        guard let mock = sessionManagerDidBlacklistJailbrokenDevice_MockMethod else {
            fatalError("no mock for `sessionManagerDidBlacklistJailbrokenDevice`")
        }

        mock()
    }

    // MARK: - sessionManagerRequireCertificateEnrollment

    public var sessionManagerRequireCertificateEnrollment_Invocations: [Void] = []
    public var sessionManagerRequireCertificateEnrollment_MockMethod: (() -> Void)?

    public func sessionManagerRequireCertificateEnrollment() {
        sessionManagerRequireCertificateEnrollment_Invocations.append(())

        guard let mock = sessionManagerRequireCertificateEnrollment_MockMethod else {
            fatalError("no mock for `sessionManagerRequireCertificateEnrollment`")
        }

        mock()
    }

    // MARK: - sessionManagerDidEnrollCertificate

    public var sessionManagerDidEnrollCertificateFor_Invocations: [UserSession?] = []
    public var sessionManagerDidEnrollCertificateFor_MockMethod: ((UserSession?) -> Void)?

    public func sessionManagerDidEnrollCertificate(for activeSession: UserSession?) {
        sessionManagerDidEnrollCertificateFor_Invocations.append(activeSession)

        guard let mock = sessionManagerDidEnrollCertificateFor_MockMethod else {
            fatalError("no mock for `sessionManagerDidEnrollCertificateFor`")
        }

        mock(activeSession)
    }

    // MARK: - sessionManagerDidPerformFederationMigration

    public var sessionManagerDidPerformFederationMigrationActiveSession_Invocations: [UserSession?] = []
    public var sessionManagerDidPerformFederationMigrationActiveSession_MockMethod: ((UserSession?) -> Void)?

    public func sessionManagerDidPerformFederationMigration(activeSession: UserSession?) {
        sessionManagerDidPerformFederationMigrationActiveSession_Invocations.append(activeSession)

        guard let mock = sessionManagerDidPerformFederationMigrationActiveSession_MockMethod else {
            fatalError("no mock for `sessionManagerDidPerformFederationMigrationActiveSession`")
        }

        mock(activeSession)
    }

    // MARK: - sessionManagerDidPerformAPIMigrations

    public var sessionManagerDidPerformAPIMigrationsActiveSession_Invocations: [UserSession?] = []
    public var sessionManagerDidPerformAPIMigrationsActiveSession_MockMethod: ((UserSession?) -> Void)?

    public func sessionManagerDidPerformAPIMigrations(activeSession: UserSession?) {
        sessionManagerDidPerformAPIMigrationsActiveSession_Invocations.append(activeSession)

        guard let mock = sessionManagerDidPerformAPIMigrationsActiveSession_MockMethod else {
            fatalError("no mock for `sessionManagerDidPerformAPIMigrationsActiveSession`")
        }

        mock(activeSession)
    }

    // MARK: - sessionManagerAsksToRetryStart

    public var sessionManagerAsksToRetryStart_Invocations: [Void] = []
    public var sessionManagerAsksToRetryStart_MockMethod: (() -> Void)?

    public func sessionManagerAsksToRetryStart() {
        sessionManagerAsksToRetryStart_Invocations.append(())

        guard let mock = sessionManagerAsksToRetryStart_MockMethod else {
            fatalError("no mock for `sessionManagerAsksToRetryStart`")
        }

        mock()
    }

    // MARK: - sessionManagerDidCompleteInitialSync

    public var sessionManagerDidCompleteInitialSyncFor_Invocations: [UserSession?] = []
    public var sessionManagerDidCompleteInitialSyncFor_MockMethod: ((UserSession?) -> Void)?

    public func sessionManagerDidCompleteInitialSync(for activeSession: UserSession?) {
        sessionManagerDidCompleteInitialSyncFor_Invocations.append(activeSession)

        guard let mock = sessionManagerDidCompleteInitialSyncFor_MockMethod else {
            fatalError("no mock for `sessionManagerDidCompleteInitialSyncFor`")
        }

        mock(activeSession)
    }

    // MARK: - sessionManagerDidChangeActiveUserSession

    public var sessionManagerDidChangeActiveUserSessionUserSession_Invocations: [ZMUserSession] = []
    public var sessionManagerDidChangeActiveUserSessionUserSession_MockMethod: ((ZMUserSession) -> Void)?

    public func sessionManagerDidChangeActiveUserSession(userSession: ZMUserSession) {
        sessionManagerDidChangeActiveUserSessionUserSession_Invocations.append(userSession)

        guard let mock = sessionManagerDidChangeActiveUserSessionUserSession_MockMethod else {
            fatalError("no mock for `sessionManagerDidChangeActiveUserSessionUserSession`")
        }

        mock(userSession)
    }

    // MARK: - sessionManagerDidReportLockChange

    public var sessionManagerDidReportLockChangeForSession_Invocations: [UserSession] = []
    public var sessionManagerDidReportLockChangeForSession_MockMethod: ((UserSession) -> Void)?

    public func sessionManagerDidReportLockChange(forSession session: UserSession) {
        sessionManagerDidReportLockChangeForSession_Invocations.append(session)

        guard let mock = sessionManagerDidReportLockChangeForSession_MockMethod else {
            fatalError("no mock for `sessionManagerDidReportLockChangeForSession`")
        }

        mock(session)
    }

}

public class MockSnoozeCertificateEnrollmentUseCaseProtocol: SnoozeCertificateEnrollmentUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invokeEndOfPeriodIsUpdateMode_Invocations: [(endOfPeriod: Date, isUpdateMode: Bool)] = []
    public var invokeEndOfPeriodIsUpdateMode_MockMethod: ((Date, Bool) async -> Void)?

    public func invoke(endOfPeriod: Date, isUpdateMode: Bool) async {
        invokeEndOfPeriodIsUpdateMode_Invocations.append((endOfPeriod: endOfPeriod, isUpdateMode: isUpdateMode))

        guard let mock = invokeEndOfPeriodIsUpdateMode_MockMethod else {
            fatalError("no mock for `invokeEndOfPeriodIsUpdateMode`")
        }

        await mock(endOfPeriod, isUpdateMode)
    }

}

public class MockStopCertificateEnrollmentSnoozerUseCaseProtocol: StopCertificateEnrollmentSnoozerUseCaseProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - invoke

    public var invoke_Invocations: [Void] = []
    public var invoke_MockMethod: (() -> Void)?

    public func invoke() {
        invoke_Invocations.append(())

        guard let mock = invoke_MockMethod else {
            fatalError("no mock for `invoke`")
        }

        mock()
    }

}

public class MockUseCaseFactoryProtocol: UseCaseFactoryProtocol {

    // MARK: - Life cycle

    public init() {}


    // MARK: - createResolveOneOnOneUseCase

    public var createResolveOneOnOneUseCase_Invocations: [Void] = []
    public var createResolveOneOnOneUseCase_MockMethod: (() -> ResolveOneOnOneConversationsUseCaseProtocol)?
    public var createResolveOneOnOneUseCase_MockValue: ResolveOneOnOneConversationsUseCaseProtocol?

    public func createResolveOneOnOneUseCase() -> ResolveOneOnOneConversationsUseCaseProtocol {
        createResolveOneOnOneUseCase_Invocations.append(())

        if let mock = createResolveOneOnOneUseCase_MockMethod {
            return mock()
        } else if let mock = createResolveOneOnOneUseCase_MockValue {
            return mock
        } else {
            fatalError("no mock for `createResolveOneOnOneUseCase`")
        }
    }

}

public class MockUserProfile: UserProfile {

    // MARK: - Life cycle

    public init() {}

    // MARK: - lastSuggestedHandle

    public var lastSuggestedHandle: String?


    // MARK: - requestPhoneVerificationCode

    public var requestPhoneVerificationCodePhoneNumber_Invocations: [String] = []
    public var requestPhoneVerificationCodePhoneNumber_MockMethod: ((String) -> Void)?

    public func requestPhoneVerificationCode(phoneNumber: String) {
        requestPhoneVerificationCodePhoneNumber_Invocations.append(phoneNumber)

        guard let mock = requestPhoneVerificationCodePhoneNumber_MockMethod else {
            fatalError("no mock for `requestPhoneVerificationCodePhoneNumber`")
        }

        mock(phoneNumber)
    }

    // MARK: - requestPhoneNumberChange

    public var requestPhoneNumberChangeCredentials_Invocations: [ZMPhoneCredentials] = []
    public var requestPhoneNumberChangeCredentials_MockMethod: ((ZMPhoneCredentials) -> Void)?

    public func requestPhoneNumberChange(credentials: ZMPhoneCredentials) {
        requestPhoneNumberChangeCredentials_Invocations.append(credentials)

        guard let mock = requestPhoneNumberChangeCredentials_MockMethod else {
            fatalError("no mock for `requestPhoneNumberChangeCredentials`")
        }

        mock(credentials)
    }

    // MARK: - requestPhoneNumberRemoval

    public var requestPhoneNumberRemoval_Invocations: [Void] = []
    public var requestPhoneNumberRemoval_MockMethod: (() -> Void)?

    public func requestPhoneNumberRemoval() {
        requestPhoneNumberRemoval_Invocations.append(())

        guard let mock = requestPhoneNumberRemoval_MockMethod else {
            fatalError("no mock for `requestPhoneNumberRemoval`")
        }

        mock()
    }

    // MARK: - requestEmailChange

    public var requestEmailChangeEmail_Invocations: [String] = []
    public var requestEmailChangeEmail_MockError: Error?
    public var requestEmailChangeEmail_MockMethod: ((String) throws -> Void)?

    public func requestEmailChange(email: String) throws {
        requestEmailChangeEmail_Invocations.append(email)

        if let error = requestEmailChangeEmail_MockError {
            throw error
        }

        guard let mock = requestEmailChangeEmail_MockMethod else {
            fatalError("no mock for `requestEmailChangeEmail`")
        }

        try mock(email)
    }

    // MARK: - requestSettingEmailAndPassword

    public var requestSettingEmailAndPasswordCredentials_Invocations: [ZMEmailCredentials] = []
    public var requestSettingEmailAndPasswordCredentials_MockError: Error?
    public var requestSettingEmailAndPasswordCredentials_MockMethod: ((ZMEmailCredentials) throws -> Void)?

    public func requestSettingEmailAndPassword(credentials: ZMEmailCredentials) throws {
        requestSettingEmailAndPasswordCredentials_Invocations.append(credentials)

        if let error = requestSettingEmailAndPasswordCredentials_MockError {
            throw error
        }

        guard let mock = requestSettingEmailAndPasswordCredentials_MockMethod else {
            fatalError("no mock for `requestSettingEmailAndPasswordCredentials`")
        }

        try mock(credentials)
    }

    // MARK: - cancelSettingEmailAndPassword

    public var cancelSettingEmailAndPassword_Invocations: [Void] = []
    public var cancelSettingEmailAndPassword_MockMethod: (() -> Void)?

    public func cancelSettingEmailAndPassword() {
        cancelSettingEmailAndPassword_Invocations.append(())

        guard let mock = cancelSettingEmailAndPassword_MockMethod else {
            fatalError("no mock for `cancelSettingEmailAndPassword`")
        }

        mock()
    }

    // MARK: - requestCheckHandleAvailability

    public var requestCheckHandleAvailabilityHandle_Invocations: [String] = []
    public var requestCheckHandleAvailabilityHandle_MockMethod: ((String) -> Void)?

    public func requestCheckHandleAvailability(handle: String) {
        requestCheckHandleAvailabilityHandle_Invocations.append(handle)

        guard let mock = requestCheckHandleAvailabilityHandle_MockMethod else {
            fatalError("no mock for `requestCheckHandleAvailabilityHandle`")
        }

        mock(handle)
    }

    // MARK: - requestSettingHandle

    public var requestSettingHandleHandle_Invocations: [String] = []
    public var requestSettingHandleHandle_MockMethod: ((String) -> Void)?

    public func requestSettingHandle(handle: String) {
        requestSettingHandleHandle_Invocations.append(handle)

        guard let mock = requestSettingHandleHandle_MockMethod else {
            fatalError("no mock for `requestSettingHandleHandle`")
        }

        mock(handle)
    }

    // MARK: - cancelSettingHandle

    public var cancelSettingHandle_Invocations: [Void] = []
    public var cancelSettingHandle_MockMethod: (() -> Void)?

    public func cancelSettingHandle() {
        cancelSettingHandle_Invocations.append(())

        guard let mock = cancelSettingHandle_MockMethod else {
            fatalError("no mock for `cancelSettingHandle`")
        }

        mock()
    }

    // MARK: - suggestHandles

    public var suggestHandles_Invocations: [Void] = []
    public var suggestHandles_MockMethod: (() -> Void)?

    public func suggestHandles() {
        suggestHandles_Invocations.append(())

        guard let mock = suggestHandles_MockMethod else {
            fatalError("no mock for `suggestHandles`")
        }

        mock()
    }

    // MARK: - add

    public var addObserver_Invocations: [UserProfileUpdateObserver] = []
    public var addObserver_MockMethod: ((UserProfileUpdateObserver) -> Any)?
    public var addObserver_MockValue: Any?

    @objc(addObserver:)
    public func add(observer: UserProfileUpdateObserver) -> Any {
        addObserver_Invocations.append(observer)

        if let mock = addObserver_MockMethod {
            return mock(observer)
        } else if let mock = addObserver_MockValue {
            return mock
        } else {
            fatalError("no mock for `addObserver`")
        }
    }

}

// swiftlint:enable variable_name
// swiftlint:enable line_length
// swiftlint:enable vertical_whitespace
// swiftlint:enable superfluous_disable_command
