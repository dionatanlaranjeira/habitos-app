import * as onReactionWrite from "./triggers/onReactionWrite";
import * as onCommentWrite from "./triggers/onCommentWrite";
import * as onCheckinWrite from "./triggers/onCheckinWrite";

// Social Interactions Triggers
export const onReactionCreated = onReactionWrite.onReactionCreated;
export const onReactionDeleted = onReactionWrite.onReactionDeleted;
export const onCommentCreated = onCommentWrite.onCommentCreated;
export const onCommentDeleted = onCommentWrite.onCommentDeleted;

// Check-ins / Ranking Triggers
export const onCheckinCreated = onCheckinWrite.onCheckinCreated;
export const getWeeklyGroupRanking = onCheckinWrite.getWeeklyGroupRanking;
