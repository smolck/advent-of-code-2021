(ns day6.core (:require [clojure.string :as str]))

;; Thank you @seandewar for this algorithm/idea!
;; 
;; Originally I had each fish as an element in the list, and that worked fine for 80 iterations,
;; but that does NOT work (at least not in this decade) for 256 iterations.
;; 
;; So the solution instead is to have the counts of each fish in a vector of length 9, and then
;; for each iteration just shift all the elements in the array to the left, and then also add the
;; day 0 fish count (which is now at day 8 because of the shifting) to the day 6 fish count.
;; 
;; Do that for as many iterations as you need and then sum up the resulting vector, and you have
;; your answer.

(defn run-generation [vs]
   (let [zeroes (first vs)
         vs-shifted (reverse (cons (first vs) (reverse (rest vs))))]
    (assoc (vec vs-shifted) 6 (+ (nth vs-shifted 6) zeroes))))

(defn -main [& args]
  (let [assoc-fn (fn [acc fish] (assoc acc fish (+ (get acc fish) 1)))
        fishes (-> (slurp "input.txt")
                   (str/replace "\n" "")
                   (str/split #",")
                   (->> (map #(Integer/parseInt %))))
        fishes-map (sort (reduce assoc-fn {0 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0 8 0} fishes))
        fishes (vec (vals fishes-map))]
      (println "Part one: " (reduce + 0 (nth (iterate run-generation fishes) 80)))
      (println "Part two: " (reduce + 0 (nth (iterate run-generation fishes) 256)))))
