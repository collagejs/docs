<script lang="ts">
    import Card from '../Card/Card.svelte';
</script>

<div class="container d-flex flex-column gap-1 align-items-center">
    <div class="row">
        <span class="phrase col"> Start learning today! </span>
    </div>
    <div class="row">
        <Card class="col-auto d-flex gap-2">
            <a href="/docs" class="cjs-btn cjs-btn-primary">Get Started</a>
            <a href="/guides/migration-from-single-spa" class="cjs-btn cjs-btn-secondary">
                Migration Guide for the <code>single-spa</code> savvy
            </a>
        </Card>
    </div>
</div>

<style>
    .phrase {
        font-size: 2rem;
    }
</style>
