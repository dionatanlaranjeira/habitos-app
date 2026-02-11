import * as onReactionWrite from "./triggers/onReactionWrite";
import * as onCommentWrite from "./triggers/onCommentWrite";
import * as onCheckinWrite from "./triggers/onCheckinWrite";
import * as groupActions from "./triggers/groupActions";

// Social Interactions Triggers
export const onReactionCreated = onReactionWrite.onReactionCreated;
export const onReactionDeleted = onReactionWrite.onReactionDeleted;
export const onCommentCreated = onCommentWrite.onCommentCreated;
export const onCommentDeleted = onCommentWrite.onCommentDeleted;

// Check-ins / Ranking Triggers
export const onCheckinCreated = onCheckinWrite.onCheckinCreated;
export const onCheckinDeleted = onCheckinWrite.onCheckinDeleted;
export const getWeeklyGroupRanking = onCheckinWrite.getWeeklyGroupRanking;

// Group actions
export const deleteCheckIn = groupActions.deleteCheckIn;
export const leaveGroup = groupActions.leaveGroup;
