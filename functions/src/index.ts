import * as onReactionWrite from "./triggers/onReactionWrite";
import * as onCommentWrite from "./triggers/onCommentWrite";

// Social Interactions Triggers
export const onReactionCreated = onReactionWrite.onReactionCreated;
export const onReactionDeleted = onReactionWrite.onReactionDeleted;
export const onCommentCreated = onCommentWrite.onCommentCreated;
export const onCommentDeleted = onCommentWrite.onCommentDeleted;
