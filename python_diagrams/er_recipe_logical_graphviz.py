from __future__ import annotations

from graphviz import Digraph
from pathlib import Path


def build_er_recipe_logical() -> Digraph:
    g = Digraph("ERDRecipeLogical", format="png")
    g.attr(rankdir="TB", splines="polyline", nodesep="1", ranksep="2", overlap="false")
    g.attr("node", fontname="Arial")
    g.attr("edge", fontname="Arial")

    def entity(node_id: str) -> None:
        g.node(node_id, node_id, shape="box")

    def relationship(node_id: str, label: str) -> None:
        g.node(node_id, label, shape="diamond")

    def attribute(node_id: str, label: str) -> None:
        g.node(node_id, label, shape="ellipse")

    # Entities (aligned to implemented storage)
    for ent in [
        "USER",
        "ADMIN",
        "CONTRIBUTOR",
        "GUEST",
        "RECIPE",
        "REVIEW",
        "SEARCH_HISTORY",
        "ACTIVITY_LOG",
        "SESSION",
        "DAILY_STAT",
        "DAILY_ACTIVE_USER",
        "DAILY_NEW_USER",
        "DAILY_VIEW",
        "LIKE",
        "FAVORITE",
        "VIEW",
    ]:
        entity(ent)

    # Relationships (Chen notation)
    relationship("rel_creates", "creates")
    relationship("rel_is_admin", "is a")
    relationship("rel_is_contributor", "is a")
    relationship("rel_is_guest", "is a")
    # Admin-specific relationships
    relationship("rel_moderates", "moderates")
    relationship("rel_manages", "manages")
    relationship("rel_views_stats", "views stats")
    relationship("rel_user_favorites", "favorites")
    relationship("rel_favorite_recipe", "favorited recipe")
    relationship("rel_user_likes", "likes")
    relationship("rel_like_recipe", "liked recipe")
    relationship("rel_user_views", "views")
    relationship("rel_view_recipe", "viewed recipe")
    relationship("rel_receives", "receives")
    relationship("rel_writes", "writes")
    relationship("rel_searches", "searches")
    relationship("rel_daily_active", "daily active")
    relationship("rel_daily_new", "daily new")
    relationship("rel_daily_views", "daily views")
    relationship("rel_active_user", "active user")
    relationship("rel_new_user", "new user")
    relationship("rel_daily_view_recipe", "daily view recipe")
    relationship("rel_starts", "starts")
    relationship("rel_tracks_users", "tracks users")
    relationship("rel_tracks_recipes", "tracks recipes")

    # Rank ordering (top-down): USER -> is a relations -> subtypes -> other entities
    with g.subgraph(name="rank_top") as s:
        s.attr(rank="min")
        s.node("USER")

    with g.subgraph(name="rank_is_a") as s:
        s.attr(rank="same")
        s.node("rel_is_admin")
        s.node("rel_is_contributor")
        s.node("rel_is_guest")

    with g.subgraph(name="rank_subtypes") as s:
        s.attr(rank="same")
        s.node("ADMIN")
        s.node("CONTRIBUTOR")
        s.node("GUEST")

    with g.subgraph(name="rank_bottom") as s:
        s.attr(rank="max")
        for n in ["RECIPE", "REVIEW", "SEARCH_HISTORY", "ACTIVITY_LOG", "SESSION", "DAILY_STAT"]:
            s.node(n)

    # Invisible chaining edges to reinforce vertical order for splines="polyline"
    # Chain through the is-a relations and subtypes to ensure top-down layout
    g.edge("USER", "rel_is_admin", style="invis")
    g.edge("rel_is_admin", "ADMIN", style="invis")
    g.edge("ADMIN", "rel_is_contributor", style="invis")
    g.edge("rel_is_contributor", "CONTRIBUTOR", style="invis")
    g.edge("CONTRIBUTOR", "rel_is_guest", style="invis")
    g.edge("rel_is_guest", "GUEST", style="invis")
    # Anchor subtypes down toward recipes
    g.edge("ADMIN", "RECIPE", style="invis")
    g.edge("CONTRIBUTOR", "RECIPE", style="invis")
    g.edge("GUEST", "RECIPE", style="invis")

    # Entity-Relationship connections with cardinalities
    g.edge("CONTRIBUTOR", "rel_creates", xlabel="1")
    g.edge("rel_creates", "RECIPE", xlabel="N")

    g.edge("USER", "rel_is_admin", xlabel="1")
    g.edge("rel_is_admin", "ADMIN", xlabel="0..1")

    g.edge("USER", "rel_is_contributor", xlabel="1")
    g.edge("rel_is_contributor", "CONTRIBUTOR", xlabel="0..1")

    g.edge("USER", "rel_is_guest", xlabel="1")
    g.edge("rel_is_guest", "GUEST", xlabel="0..1")

    g.edge("ADMIN", "rel_moderates", xlabel="1")
    g.edge("rel_moderates", "RECIPE", xlabel="N")

    g.edge("ADMIN", "rel_manages", xlabel="1")
    g.edge("rel_manages", "USER", xlabel="N")


    g.edge("ADMIN", "rel_views_stats", xlabel="1")
    g.edge("rel_views_stats", "DAILY_STAT", xlabel="M")

    g.edge("CONTRIBUTOR", "rel_user_favorites", xlabel="1")
    g.edge("rel_user_favorites", "FAVORITE", xlabel="N")
    g.edge("FAVORITE", "rel_favorite_recipe", xlabel="N")
    g.edge("rel_favorite_recipe", "RECIPE", xlabel="1")

    g.edge("CONTRIBUTOR", "rel_user_likes", xlabel="1")
    g.edge("rel_user_likes", "LIKE", xlabel="N")
    g.edge("LIKE", "rel_like_recipe", xlabel="N")
    g.edge("rel_like_recipe", "RECIPE", xlabel="1")

    g.edge("CONTRIBUTOR", "rel_user_views", xlabel="1")
    g.edge("rel_user_views", "VIEW", xlabel="N")
    g.edge("GUEST", "rel_user_views", xlabel="1")
    g.edge("VIEW", "rel_view_recipe", xlabel="N")
    g.edge("rel_view_recipe", "RECIPE", xlabel="1")

    g.edge("RECIPE", "rel_receives", xlabel="1")
    g.edge("rel_receives", "REVIEW", xlabel="N")

    g.edge("CONTRIBUTOR", "rel_writes", xlabel="1")
    g.edge("rel_writes", "REVIEW", xlabel="N")

    g.edge("CONTRIBUTOR", "rel_searches", xlabel="1")
    g.edge("rel_searches", "SEARCH_HISTORY", xlabel="N")
    g.edge("GUEST", "rel_searches", xlabel="1")
    g.edge("rel_searches", "SEARCH_HISTORY", xlabel="N")

    g.edge("CONTRIBUTOR", "rel_starts", xlabel="1")
    g.edge("rel_starts", "SESSION", xlabel="N")
    g.edge("GUEST", "rel_starts", xlabel="1")
    g.edge("rel_starts", "SESSION", xlabel="N")

    g.edge("DAILY_STAT", "rel_daily_active", xlabel="1")
    g.edge("rel_daily_active", "DAILY_ACTIVE_USER", xlabel="N")
    g.edge("DAILY_STAT", "rel_daily_new", xlabel="1")
    g.edge("rel_daily_new", "DAILY_NEW_USER", xlabel="N")
    g.edge("DAILY_STAT", "rel_daily_views", xlabel="1")
    g.edge("rel_daily_views", "DAILY_VIEW", xlabel="N")

    g.edge("USER", "rel_active_user", xlabel="1")
    g.edge("rel_active_user", "DAILY_ACTIVE_USER", xlabel="N")
    g.edge("USER", "rel_new_user", xlabel="1")
    g.edge("rel_new_user", "DAILY_NEW_USER", xlabel="N")

    g.edge("DAILY_STAT", "rel_tracks_users", xlabel="1")
    g.edge("rel_tracks_users", "USER", xlabel="M")

    g.edge("DAILY_STAT", "rel_tracks_recipes", xlabel="1")
    g.edge("rel_tracks_recipes", "RECIPE", xlabel="M")

    g.edge("DAILY_VIEW", "rel_daily_view_recipe", xlabel="N")
    g.edge("rel_daily_view_recipe", "RECIPE", xlabel="1")


    # Attributes (from implemented storage)
    for node_id, attrs in {
        "USER": [],
        "ADMIN": [
            "user_id (PK, FK)",
            "role (admin)",
        ],
        "CONTRIBUTOR": [
            "user_id (PK, FK)",
            "role (user)",
            "status (active)",
        ],
        "GUEST": [
            "user_id (PK, FK)",
            "status (pending/suspended)",
        ],
        "RECIPE": [
            "recipe_id (PK)",
            "author_id (FK)",
            "status",
            "title",
            "description",
            "category",
            "prep_time",
            "cook_time",
            "servings",
            "difficulty",
            "instructions",
            "images",
            "liked_by",
            "viewed_by",
            "created_at",
        ],
        "REVIEW": [
            "review_id (PK)",
            "recipe_id (FK)",
            "user_id (FK)",
            "username",
            "avatar",
            "rating",
            "comment",
            "unique (user_id, recipe_id)",
            "created_at",
        ],
        "SEARCH_HISTORY": [
            "search_id (PK)",
            "user_id (FK)",
            "query",
            "created_at",
        ],
        "ACTIVITY_LOG": [
            "activity_id (PK)",
            "time",
            "type",
            "text",
        ],
        "SESSION": [
            "session_id (PK)",
            "user_id (FK)",
            "started_at",
            "last_seen",
        ],
        "DAILY_STAT": [
            "date_key (PK)",
        ],
        "DAILY_ACTIVE_USER": [
            "active_id (PK)",
            "date_key (FK)",
            "user_id (FK)",
        ],
        "DAILY_NEW_USER": [
            "new_id (PK)",
            "date_key (FK)",
            "user_id (FK)",
        ],
        "DAILY_VIEW": [
            "daily_view_id (PK)",
            "date_key (FK)",
            "viewer_key",
            "viewer_type",
            "recipe_id (FK)",
            "viewed_at",
        ],
        "LIKE": [
            "like_id (PK)",
            "user_id (FK)",
            "recipe_id (FK)",
            "created_at",
        ],
        "FAVORITE": [
            "favorite_id (PK)",
            "user_id (FK)",
            "recipe_id (FK)",
            "created_at",
        ],
        "VIEW": [
            "view_id (PK)",
            "viewer_key",
            "viewer_type",
            "recipe_id (FK)",
            "viewed_at",
        ],
    }.items():
        for idx, attr in enumerate(attrs, start=1):
            attr_id = f"{node_id}_attr_{idx}"
            attribute(attr_id, attr)
            g.edge(node_id, attr_id)

    # Composite multivalued ingredients attribute
    ingredient_attr = "RECIPE_attr_ingredients"
    attribute(ingredient_attr, "ingredient (multi)")
    g.edge("RECIPE", ingredient_attr)
    ingredient_name = "RECIPE_attr_ingredient_name"
    ingredient_qty = "RECIPE_attr_ingredient_quantity"
    ingredient_unit = "RECIPE_attr_ingredient_unit"
    attribute(ingredient_name, "name")
    attribute(ingredient_qty, "quantity")
    attribute(ingredient_unit, "unit")
    g.edge(ingredient_attr, ingredient_name)
    g.edge(ingredient_attr, ingredient_qty)
    g.edge(ingredient_attr, ingredient_unit)

    return g


def main() -> None:
    out_dir = Path(__file__).parent / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    g = build_er_recipe_logical()
    g.render(out_dir / "er_recipe_logical", cleanup=True)


if __name__ == "__main__":
    main()
