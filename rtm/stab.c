#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "internal.h"

int
stab_page_init(struct stab *pool, size_t count)
{
	char *buf;
	
	if (!(buf = calloc(count, pool->obj_size)))
		return 1;
	
	pool->cur->start = buf;
	pool->cur->end = buf + pool->obj_size * count;
	pool->cur->next = buf;
	
	for (; buf != pool->cur->end; buf += pool->obj_size) {
		struct cell_void *cell = (struct cell_void *)buf;
		
		cell->stab_page = pool->cur;
	}
	
	return 0;
}

int
stab_init(struct stab *pool, size_t pgcnt, size_t count, size_t size)
{
	struct stab_page *pages;
	
	if (!(pages = calloc(pgcnt, sizeof(*pages))))
		return 1;
	
	pool->start = pages;
	pool->end = pages + pgcnt;
	pool->cur = pages;
	pool->obj_size = size;
	
	return stab_page_init(pool, count);
}

size_t alloc_call_count = 0;
size_t alloc_next_count = 0;
size_t alloc_page_count = 0;
size_t alloc_free_count = 0;

void *
stab_alloc(struct stab *pool)
{
	void *obj = NULL;
	
	alloc_call_count++;
	
	while (pool->cur != pool->end) {
		struct stab_page *page = pool->cur;
		
		alloc_page_count++;
		
		if (!page->start) {
			struct stab_page *prev;
			size_t count;
			
			prev = page - 1;
			count = (prev->end - prev->start) / pool->obj_size;
			
			if (stab_page_init(pool, 2 * count))
				goto done;
		}
		
		while (page->next != page->end) {
			struct cell_void *cell = (struct cell_void *)page->next;
		
			alloc_next_count++;
			
			page->next += pool->obj_size;
			
			if (!cell->refc) {
				obj = cell;
				goto done;
			}
		}
		
		pool->cur++;
	}

done:
	return obj;
}

void
stab_free(struct stab *pool, void *obj)
{
	struct cell_void *cell = obj;
	struct stab_page *page = cell->stab_page;
	
	alloc_free_count++;
	
	if ((char *)cell < page->next)
		page->next = (char *)cell;
	
	if (page < pool->cur)
		pool->cur = page;
}

DECLSPEC void
print_memstats(void)
{
	printf("Memory Statistics:\n");
	printf("\tallocation count: %zd\n", alloc_call_count);
	printf("\tfree count: %zd\n", alloc_free_count);
	printf("\tpage count: %zd\n", alloc_page_count);
	printf("\tnext count: %zd\n", alloc_next_count);
	
	print_array_pool_stats();
}