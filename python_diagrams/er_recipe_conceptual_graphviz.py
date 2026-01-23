from __future__ import annotations

from graphviz import Digraph
from pathlib import Path


def build_er_recipe_conceptual() -> Digraph:
    g = Digraph("ERDRecipeConceptual", format="png")
    g.attr(rankdir="TB", splines="polyline", nodesep="1", ranksep="2", overlap="false")
    g.attr("node", fontname="Arial")
    g.attr("edge", fontname="Arial")

    def entity(node_id: str) -> None:
        g.node(node_id, node_id, shape="box")

    def relationship(node_id: str, label: str) -> None:
        g.node(node_id, label, shape="diamond")

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
    relationship("rel_favorites", "favorites")
    relationship("rel_likes", "likes")
    relationship("rel_views", "views")
    relationship("rel_receives", "receives")
    relationship("rel_writes", "writes")
    relationship("rel_searches", "searches")
    relationship("rel_starts", "starts")
    relationship("rel_tracks_users", "tracks users")
    relationship("rel_tracks_recipes", "tracks recipes")

    # Connections with cardinalities
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

    g.edge("CONTRIBUTOR", "rel_favorites", xlabel="M")
    g.edge("rel_favorites", "RECIPE", xlabel="M")

    g.edge("CONTRIBUTOR", "rel_likes", xlabel="M")
    g.edge("rel_likes", "RECIPE", xlabel="M")

    g.edge("CONTRIBUTOR", "rel_views", xlabel="M")
    g.edge("rel_views", "RECIPE", xlabel="M")
    g.edge("GUEST", "rel_views", xlabel="M")
    g.edge("rel_views", "RECIPE", xlabel="M")

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

    g.edge("DAILY_STAT", "rel_tracks_users", xlabel="1")
    g.edge("rel_tracks_users", "CONTRIBUTOR", xlabel="M")
    g.edge("rel_tracks_users", "GUEST", xlabel="M")

    g.edge("DAILY_STAT", "rel_tracks_recipes", xlabel="1")
    g.edge("rel_tracks_recipes", "RECIPE", xlabel="M")

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

    return g


def main() -> None:
    out_dir = Path(__file__).parent / "out"
    out_dir.mkdir(parents=True, exist_ok=True)
    g = build_er_recipe_conceptual()
    g.render(out_dir / "er_recipe_conceptual", cleanup=True)


if __name__ == "__main__":
    main()
