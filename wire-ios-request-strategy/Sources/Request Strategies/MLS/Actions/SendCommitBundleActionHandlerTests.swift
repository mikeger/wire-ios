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

@testable import WireRequestStrategy
import XCTest

class SendCommitBundleActionHandlerTests: ActionHandlerTestBase<SendCommitBundleAction, SendCommitBundleActionHandler> {

    let commitBundle = "bundle".data(using: .utf8)!

    override func setUp() {
        super.setUp()
        action = SendCommitBundleAction(commitBundle: commitBundle)
        handler = SendCommitBundleActionHandler(context: syncMOC)
    }

    // MARK: - Request generation
    func test_itGenerateARequest_APIV5() throws {
        try test_itGeneratesARequest(
            for: action,
            expectedPath: "/v5/mls/commit-bundles",
            expectedMethod: .post,
            expectedData: commitBundle,
            expectedContentType: "message/mls",
            apiVersion: .v5
        )
    }

    func test_itFailsToGenerateRequests_APIBelowV5() {
        [.v0, .v1, .v2, .v3, .v4].forEach {
            test_itDoesntGenerateARequest(
                action: action,
                apiVersion: $0,
                expectedError: .endpointUnavailable
            )
        }

        test_itDoesntGenerateARequest(
            action: SendCommitBundleAction(commitBundle: Data()),
            apiVersion: .v5,
            expectedError: .malformedRequest
        )
    }

    // MARK: - Response handling

    func test_itHandlesSuccess() throws {
        // Given
        let payload: [AnyHashable: Any] = [
            "events": [
                [
                    "time": "2021-05-12T10:52:02.671Z",
                    "type": "conversation.member-join",
                    "from": "99db9768-04e3-4b5d-9268-831b6a25c4ab",
                    "qualified_conversation": [
                        "domain": "example.com",
                        "id": "99db9768-04e3-4b5d-9268-831b6a25c4ab"
                    ],
                    "qualified_from": [
                        "domain": "example.com",
                        "id": "99db9768-04e3-4b5d-9268-831b6a25c4ab"
                    ],
                    "data": []
                ]
            ],
            "time": "2021-05-12T10:52:02.671Z"
        ]

        // When
        let updateEvents = try XCTUnwrap(test_itHandlesSuccess(
            status: 201,
            payload: payload as ZMTransportData
        ))

        XCTAssertEqual(updateEvents.count, 1)
        XCTAssertEqual(updateEvents.first?.type, .conversationMemberJoin)
    }

    func test_itHandlesFailures() {
        test_itHandlesFailures([
            .failure(status: 400, error: .mlsWelcomeMismatch, label: "mls-welcome-mismatch"),
            .failure(status: 400, error: .mlsGroupConversationMismatch, label: "mls-group-conversation-mismatch"),
            .failure(status: 400, error: .mlsClientSenderUserMismatch, label: "mls-client-sender-user-mismatch"),
            .failure(status: 400, error: .mlsSelfRemovalNotAllowed, label: "mls-self-removal-not-allowed"),
            .failure(status: 400, error: .mlsCommitMissingReferences, label: "mls-commit-missing-references"),
            .failure(status: 400, error: .mlsProtocolError, label: "mls-protocol-error"),
            .failure(status: 400, error: .invalidRequestBody),
            .failure(status: 403, error: .mlsMissingSenderClient, label: "mls-missing-sender-client"),
            .failure(status: 403, error: .missingLegalHoldConsent, label: "missing-legalhold-consent"),
            .failure(status: 403, error: .legalHoldNotEnabled, label: "legalhold-not-enabled"),
            .failure(status: 403, error: .accessDenied, label: "access-denied"),
            .failure(status: 404, error: .mlsProposalNotFound, label: "mls-proposal-not-found"),
            .failure(status: 404, error: .mlsKeyPackageRefNotFound, label: "mls-key-package-ref-not-found"),
            .failure(status: 404, error: .noConversation, label: "no-conversation"),
            .failure(status: 404, error: .noConversationMember, label: "no-conversation-member"),
            .failure(status: 409, error: .mlsStaleMessage, label: "mls-stale-message"),
            .failure(status: 409, error: .mlsClientMismatch, label: "mls-client-mismatch"),
            .failure(status: 422, error: .mlsUnsupportedProposal, label: "mls-unsupported-proposal"),
            .failure(status: 422, error: .mlsUnsupportedMessage, label: "mls-unsupported-message"),
            .failure(status: 999, error: .unknown(status: 999, label: "foo", message: "?"), label: "foo")
        ])
    }

    func test_itHandlesUnreachableBackendsFailure() {
        let domains = ["example.com"]
        let payload = ["unreachable_backends": domains]
        test_itHandlesFailure(
            status: 533,
            payload: payload as ZMTransportData,
            expectedError: SendCommitBundleAction.Failure.unreachableDomains(Set(domains)))
    }

    func test_itHandlesNonFederatingBackendsFailure() {
        let domains = ["example.com"]
        let payload = ["non_federating_backends": domains]
        test_itHandlesFailure(
            status: 409,
            payload: payload as ZMTransportData,
            expectedError: SendCommitBundleAction.Failure.nonFederatingDomains(Set(domains)))
    }
}
