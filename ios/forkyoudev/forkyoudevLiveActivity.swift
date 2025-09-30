//
//  forkyoudevLiveActivity.swift
//  forkyoudev
//
//  Created by AKSHU on 25/09/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct forkyoudevAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct forkyoudevLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: forkyoudevAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension forkyoudevAttributes {
    fileprivate static var preview: forkyoudevAttributes {
        forkyoudevAttributes(name: "World")
    }
}

extension forkyoudevAttributes.ContentState {
    fileprivate static var smiley: forkyoudevAttributes.ContentState {
        forkyoudevAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: forkyoudevAttributes.ContentState {
         forkyoudevAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: forkyoudevAttributes.preview) {
   forkyoudevLiveActivity()
} contentStates: {
    forkyoudevAttributes.ContentState.smiley
    forkyoudevAttributes.ContentState.starEyes
}
