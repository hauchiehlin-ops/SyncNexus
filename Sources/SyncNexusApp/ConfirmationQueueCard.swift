import SwiftUI
import SyncCore

/// Lists every sync group that is holding back an abnormal change (e.g. mass deletion) and lets the user
/// review, approve or decline each one — or approve them all — without switching groups first.
struct ConfirmationQueueCard: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let items = model.groupsNeedingConfirmation
        if !items.isEmpty {
            Card {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.raised").foregroundStyle(Theme.warn)
                        Text(loc("confirm_queue_title", items.count)).font(.system(size: 14, weight: .semibold))
                        Spacer()
                        if items.count > 1 {
                            Button(loc("confirm_queue_approve_all")) { model.approveAllConfirmations() }
                                .buttonStyle(QuietButton(kind: .dark))
                        }
                    }
                    ForEach(items, id: \.group.id) { item in
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: item.group.icon).foregroundStyle(Color.accentColor)
                                Text(model.groupName(item.group)).font(.system(size: 13, weight: .semibold))
                            }
                            Text(item.reason).font(.system(size: 12)).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            HStack(spacing: 8) {
                                Button(loc("confirm_queue_details")) { model.reviewConfirmation(group: item.group.id) }
                                    .buttonStyle(QuietButton(kind: .secondary))
                                Spacer()
                                Button(loc("confirm_queue_decline")) { model.declineConfirmation(group: item.group.id) }
                                    .buttonStyle(QuietButton(kind: .secondary))
                                Button(loc("confirm_queue_approve")) { model.approveConfirmation(group: item.group.id) }
                                    .buttonStyle(QuietButton(kind: .dark))
                            }
                        }
                    }
                    Text(loc("confirm_queue_hint")).font(.system(size: 11)).foregroundStyle(.secondary)
                }
            }
        }
    }
}
