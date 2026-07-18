export type ArticleDefinition = {
    title: string;
    href: string;
};

export type ArticleGroupDefinition = {
    title: string;
    articles: ArticleNode[];
};

export type ArticleNode = ArticleDefinition | ArticleGroupDefinition;
