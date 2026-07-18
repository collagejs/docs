import type { ArticleGroupDefinition, ArticleNode } from "../../types.js";

export function isArticleGroupDefinition(node: ArticleNode): node is ArticleGroupDefinition {
    return (node as ArticleGroupDefinition).articles !== undefined;
}
