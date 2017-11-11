#include "eval.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int card_ptr_comp(const void * vp1, const void * vp2) {
  return 0;
}

suit_t flush_suit(deck_t * hand) {
 return NUM_SUITS;
}

unsigned get_largest_element(unsigned * arr, size_t n) {
 return 0;
}

size_t get_match_index(unsigned * match_counts, size_t n,unsigned n_of_akind){

 return 0;
}
ssize_t  find_secondary_pair(deck_t * hand,
			     unsigned * match_counts,
			     size_t match_idx) {
  return -1;
}

int is_straight_at(deck_t * hand, size_t index, suit_t fs) {
  return 0;
}

hand_eval_t build_hand_from_match(deck_t * hand,
				  unsigned n,
				  hand_ranking_t what,
				  size_t idx) {

  hand_eval_t ans;
  return ans;
}


int compare_hands(deck_t * hand1, deck_t * hand2) {

  return 0;
}
