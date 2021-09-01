theory Tutte_theorem
  imports Bipartite
begin

definition odd_components where
  "odd_components E = {C. \<exists> v \<in> Vs E. connected_component E v = C \<and> odd (card C)}"

definition even_components where
  "even_components E = {C. \<exists> v \<in> Vs E. connected_component E v = C \<and> even (card C)}"

definition count_odd_components where
  "count_odd_components E = card (odd_components E)"

definition graph_diff where
  "graph_diff E X = {e. e \<in> E \<and> e \<inter> X = {}}"

definition singleton_in_diff where 
  "singleton_in_diff E X = {a. \<exists> v. a = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)}"

definition diff_odd_components where
  "diff_odd_components E X = (odd_components (graph_diff E X)) \<union> (singleton_in_diff E X)"

definition count_diff_odd_components where
  "count_diff_odd_components E X = card (diff_odd_components E X)"

definition tutte_condition where
  "tutte_condition E \<equiv> \<forall> X \<subseteq> Vs E. card (diff_odd_components E X) \<le> card X"

definition barrier where
  "barrier E X \<equiv> X \<noteq> {} \<and> card (diff_odd_components E X) = card X"

lemma connected_component_not_singleton:
  assumes "graph_invar E"
  assumes "v\<in> Vs E"
  shows "card (connected_component E v) > 1"
proof -
  have "\<exists>e \<in> E. v \<in> e" using assms 
    by (meson vs_member_elim)
  then obtain e where "e \<in> E" "v \<in> e" by auto
  then have "\<exists>u \<in> Vs E. \<exists> t \<in> Vs E.  e = {t, u}" 
    by (metis assms(1) edges_are_Vs insert_commute)
  then obtain u t where "u \<in> Vs E" "t \<in> Vs E" "e = {t, u}" by auto

  show ?thesis 
    by (smt (verit, best) \<open>e = {t, u}\<close> \<open>e \<in> E\<close> \<open>u \<in> Vs E\<close> \<open>v \<in> e\<close> assms(1) card_0_eq card_1_singletonE connected_component_subs_Vs connected_components_closed' doubleton_eq_iff finite_subset in_con_comp_insert insert_absorb insert_iff less_one linorder_neqE_nat own_connected_component_unique)
qed

lemma werew:
  assumes "finite (Vs M)"
  assumes "matching M"
  assumes " C \<subseteq> M "
  shows "card ( Vs C) = sum (\<lambda> e. card e) (C)" 
proof -
  have "finite M" using assms(1) 
    by (metis Vs_def finite_UnionD)
  then have "finite C"  
    using assms(3) finite_subset by auto
  show ?thesis using `finite C` assms(3)
  proof(induct C)
    case empty
    then show ?case 
      by (simp add: Vs_def)
  next
    case (insert x F)
    have "finite F" 
      by (simp add: insert.hyps(1))
    then have "finite (Vs F)" 
      by (meson Vs_subset assms(1) finite_subset insert.prems insert_subset)
    have "finite {x}"  by auto
    have "F \<subseteq> M"
      using insert.prems by auto
    then have "card (Vs F) = sum card F"
      using insert.hyps(3) by blast
    have "x \<in> M" 
      using insert.prems by auto
    then have "\<forall>y \<in> F. x \<inter> y = {}" 
      by (metis Int_emptyI \<open>F \<subseteq> M\<close> assms(2) insert.hyps(2) matching_unique_match subset_iff)
    then have "Vs F \<inter> Vs {x} = {}" 
      by (metis Int_commute Sup_empty Sup_insert Vs_def assms(2) insert.hyps(2) insert.prems insert_partition matching_def subsetD sup_bot_right)
    have "card ((Vs F) \<union> (Vs {x})) = card (Vs F) + card (Vs {x})" 
      by (metis Sup_empty Sup_insert Vs_def Vs_subset \<open>Vs F \<inter> Vs {x} = {}\<close> assms(1) card_Un_disjoint finite_Un finite_subset insert.prems sup_bot_right)
    then have "card (Vs (insert x F)) = card (Vs F) + card x"
      by (simp add: Vs_def sup_commute)
    then show ?case 
      by (simp add: \<open>card (Vs F) = sum card F\<close> insert.hyps(1) insert.hyps(2))
  qed
qed

lemma werew2:
  assumes "finite (Vs M)"
  assumes "matching M"
  assumes " C \<subseteq> M "
  shows "card ((Vs C) \<inter> X) = sum (\<lambda> e. card (e \<inter> X)) (C)" 
proof -
  have "finite M" using assms(1) 
    by (metis Vs_def finite_UnionD)
  then have "finite C"  
    using assms(3) finite_subset by auto
  show ?thesis using `finite C` assms(3)
  proof(induct C)
    case empty
    then show ?case   by (simp add: Vs_def)
  next
    case (insert x F)
    have "finite F" 
      by (simp add: insert.hyps(1))
    then have "finite (Vs F)" 
      by (meson Vs_subset assms(1) finite_subset insert.prems insert_subset)
    have "finite {x}"  by auto
    have "F \<subseteq> M"
      using insert.prems by auto
    then have "card (Vs F \<inter> X) = (\<Sum>e\<in>F. card (e \<inter> X))"
      using insert.hyps(3) by blast
    have "x \<in> M" 
      using insert.prems by auto
    then have "\<forall>y \<in> F. x \<inter> y = {}" 
      by (metis Int_emptyI \<open>F \<subseteq> M\<close> assms(2) insert.hyps(2) matching_unique_match subset_iff)
    then have "Vs F \<inter> Vs {x} = {}" 
      by (metis Int_commute Sup_empty Sup_insert Vs_def assms(2) insert.hyps(2) insert.prems insert_partition matching_def subsetD sup_bot_right)
    have "card ((Vs F \<inter> X) \<union> (Vs {x} \<inter> X)) = card (Vs F \<inter> X) + card (Vs {x} \<inter> X)" 

      by (smt (verit, ccfv_threshold) Int_Un_eq(2) Int_ac(3) Sup_empty Sup_insert Vs_def Vs_subset \<open>Vs F \<inter> Vs {x} = {}\<close> \<open>finite (Vs F)\<close> assms(1) boolean_algebra_cancel.inf2 card_Un_disjoint finite_Int finite_subset inf_sup_absorb insert.prems sup_bot_right)
    then have "card (Vs (insert x F) \<inter> X ) = card (Vs F \<inter> X) + card (x \<inter> X)"    
      by (metis Int_Un_distrib2 Sup_empty Sup_insert Un_left_commute Vs_def sup_bot_right)
    then show ?case 
      by (simp add: \<open>card (Vs F \<inter> X) = (\<Sum>e\<in>F. card (e \<inter> X))\<close> insert.hyps(1) insert.hyps(2))
  qed
qed


lemma graph_diff_subset: "graph_diff E X \<subseteq> E"
  by (simp add: graph_diff_def)

lemma connected_component_subset:
  assumes "v \<in> Vs E"
  shows "connected_component E v \<subseteq> Vs E"
  using assms by (metis in_connected_component_in_edges subsetI)

lemma diff_connected_component_subset:
  assumes "v \<in> Vs E"
  shows "connected_component (graph_diff E X) v \<subseteq> Vs E" 
  by (meson assms con_comp_subset connected_component_subset dual_order.trans graph_diff_subset)

lemma component_in_E:
  assumes "C \<in> (diff_odd_components E X)"
  shows "C \<subseteq> Vs E"
proof(cases "C \<in> (odd_components (graph_diff E X))")
  case True
  then have "\<exists> v \<in> Vs (graph_diff E X). connected_component (graph_diff E X) v = C"
    unfolding odd_components_def 
    by blast
  then show ?thesis 
    by (metis diff_connected_component_subset graph_diff_subset subset_eq vs_member)
next
  case False
  have "C \<in> (singleton_in_diff E X)" 
    by (metis False UnE assms diff_odd_components_def)
  then show ?thesis 
    by (smt (z3) Diff_eq_empty_iff Diff_subset_conv Un_upper1 insert_subset mem_Collect_eq singleton_in_diff_def)
qed

lemma card_sum_is_multiplication:
  fixes k :: real
  assumes "finite A"
  shows "sum (\<lambda> e. k) A = k * (card A)"

  by simp


lemma union_card_is_sum:
  fixes f :: "'a set \<Rightarrow> 'a set" 
  assumes "finite A"
  assumes "\<forall>C \<in> A. finite (f C)" 
  assumes "\<forall> C1 \<in> A. \<forall> C2 \<in> A. C1 \<noteq> C2 \<longrightarrow> f C1 \<inter> f C2 = {}"
  shows "sum (\<lambda> C. card (f C)) A = card (\<Union>C\<in>A. (f C))" using assms
proof(induct A)
  case empty
  then show ?case 
    by simp
next
  case (insert x F)
  then have "\<forall>C1\<in> F. \<forall>C2\<in> F. C1 \<noteq> C2 \<longrightarrow> f C1 \<inter> f C2 = {}" using insert.prems
    by simp
  then have " (\<Sum>C\<in>F. card (f C)) =  card (\<Union> (f ` F))"
    using insert.hyps(3) 
    by (simp add: insert.prems(1))
  have "\<Union> (f ` (insert x F)) = (\<Union> (f ` F)) \<union> f x" 
    by blast
  have "\<Union> (f ` F) \<inter> f x = {}" 
    using insert.hyps(2) insert.prems by fastforce
  then have " card ((\<Union> (f ` F)) \<union> f x) =  card (\<Union> (f ` F)) + card (f x)" 
    by (meson card_Un_disjoint finite_UN_I insert.hyps(1) insert.prems(1) insertCI)
  then have "card (\<Union> (f ` (insert x F))) = card (\<Union> (f ` F)) + card (f x)"
    using \<open>\<Union> (f ` insert x F) = \<Union> (f ` F) \<union> f x\<close> by presburger
  then show ?case 
    by (simp add: \<open>(\<Sum>C\<in>F. card (f C)) = card (\<Union> (f ` F))\<close> insert.hyps(1) insert.hyps(2))
qed  

lemma diff_odd_components_not_in_X:
  assumes "C \<in> (diff_odd_components E X)"
  shows  "C \<inter> X = {}"
proof(rule ccontr)
  assume "C \<inter> X \<noteq> {}"
  then obtain c where "c \<in> C" "c \<in> X" by blast
  show False
  proof(cases "C \<in> (odd_components (graph_diff E X))")
    case True
    then have "\<exists> v \<in> Vs (graph_diff E X). connected_component (graph_diff E X) v = C" 
      using odd_components_def by auto
    then have "connected_component (graph_diff E X) c = C" 
      by (metis \<open>c \<in> C\<close> connected_components_member_eq)

    then have "c \<in> Vs (graph_diff E X)"
      by (metis \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>c \<in> C\<close> in_connected_component_in_edges)

    then show ?thesis unfolding graph_diff_def  
      by (smt (verit) \<open>c \<in> X\<close> insert_Diff insert_disjoint(1) mem_Collect_eq vs_member)
  next
    case False
    then have "C \<in>  (singleton_in_diff E X)"
      using \<open>C \<in> diff_odd_components E X\<close> diff_odd_components_def by auto
    then have "\<exists>v. C = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)" unfolding 
        singleton_in_diff_def 
      by blast
    then show ?thesis 
      using \<open>c \<in> C\<close> \<open>c \<in> X\<close> by blast
  qed
qed

lemma diff_component_disjoint:
  assumes "graph_invar E"
  assumes "C1 \<in> (diff_odd_components E X)"
  assumes "C2 \<in> (diff_odd_components E X)"
  assumes "C1 \<noteq> C2"
  shows "C1 \<inter> C2 = {}" using connected_components_disj
proof(cases "C1 \<in> (odd_components (graph_diff E X))")
  case True

  show ?thesis
  proof(rule ccontr)
    assume "C1 \<inter> C2 \<noteq> {}"
    then have "\<exists>u. u \<in> C1 \<inter> C2" by auto
    then  obtain u where "u \<in> C1 \<inter> C2" by auto
    then have "connected_component (graph_diff E X) u = C1" 
      using True unfolding odd_components_def 
      using connected_components_member_eq by force
    then have "card C1 > 1" using connected_component_not_singleton
      by (smt (verit, del_insts) True Vs_subset assms(1) finite_subset graph_diff_subset mem_Collect_eq odd_components_def subset_eq)
    show False 
    proof(cases "C2 \<in> (odd_components (graph_diff E X))")
      case True
      then have "\<exists> v \<in> Vs (graph_diff E X). connected_component (graph_diff E X) v = C2"
        using odd_components_def 
        by auto
      have "u \<in> C2" using `u \<in> C1 \<inter> C2` by auto
      then have "connected_component (graph_diff E X) u = C2" 
        by (metis \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C2\<close> connected_components_member_eq)

      then show ?thesis 
        by (simp add: \<open>C1 \<noteq> C2\<close> \<open>connected_component (graph_diff E X) u = C1\<close>)
    next
      case False
      then have "C2 \<in> (singleton_in_diff E X)" 
        by (metis UnE \<open>C2 \<in> diff_odd_components E X\<close> diff_odd_components_def)
      then have " \<exists> v. C2 = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)"
        by (simp add: singleton_in_diff_def)
      have "C2 = {u}" 
        using \<open>\<exists>v. C2 = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)\<close> \<open>u \<in> C1 \<inter> C2\<close> by fastforce
      then have "u \<notin> X \<and> u \<notin> Vs (graph_diff E X)" 
        using \<open>\<exists>v. C2 = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)\<close> by fastforce
      then show ?thesis 
        by (metis \<open>C1 \<noteq> C2\<close> \<open>C2 = {u}\<close> \<open>connected_component (graph_diff E X) u = C1\<close> connected_components_notE_singletons)
    qed
  qed
next
  case False
  then have "C1 \<in> (singleton_in_diff E X)" 
    by (metis UnE \<open>C1 \<in> diff_odd_components E X\<close> diff_odd_components_def)
  then have " \<exists> v. C1 = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)"
    by (simp add: singleton_in_diff_def)
  then obtain u where " C1 = {u} \<and> u \<in> Vs E \<and> u \<notin> X \<and> u \<notin> Vs (graph_diff E X)" by auto

  show ?thesis
  proof(rule ccontr)
    assume "C1 \<inter> C2 \<noteq> {}"
    then have "u \<in> C2" 
      by (simp add: \<open>C1 = {u} \<and> u \<in> Vs E \<and> u \<notin> X \<and> u \<notin> Vs (graph_diff E X)\<close>)
    show False
    proof(cases "C2 \<in> (odd_components (graph_diff E X))")
      case True
      have "\<exists> v \<in> Vs E. connected_component E v = C2" 
        by (smt (verit, best) True \<open>C1 = {u} \<and> u \<in> Vs E \<and> u \<notin> X \<and> u \<notin> Vs (graph_diff E X)\<close> \<open>u \<in> C2\<close> in_connected_component_in_edges mem_Collect_eq odd_components_def)
      then have "connected_component E u = C2" 
        by (metis \<open>u \<in> C2\<close> connected_components_member_eq)
      then show ?thesis 
        by (smt (verit) True \<open>C1 = {u} \<and> u \<in> Vs E \<and> u \<notin> X \<and> u \<notin> Vs (graph_diff E X)\<close> \<open>u \<in> C2\<close> in_connected_component_in_edges mem_Collect_eq odd_components_def)
    next
      case False
      then have "C2 = {u}" 
        by (smt (verit, ccfv_threshold) UnE \<open>C2 \<in> diff_odd_components E X\<close> \<open>u \<in> C2\<close> diff_odd_components_def mem_Collect_eq mk_disjoint_insert singleton_in_diff_def singleton_insert_inj_eq')
      then show ?thesis 
        using \<open>C1 = {u} \<and> u \<in> Vs E \<and> u \<notin> X \<and> u \<notin> Vs (graph_diff E X)\<close> \<open>C1 \<noteq> C2\<close> by blast
    qed
  qed
qed

lemma tutte1:
  assumes "\<exists>M. perfect_matching E M"
  shows "tutte_condition E"
proof(rule ccontr)
  obtain M where "perfect_matching E M" using assms by auto
  assume "\<not> tutte_condition E"
  then have "\<exists> X \<subseteq> Vs E. card (diff_odd_components E X) > card X" unfolding tutte_condition_def
    by (meson le_less_linear)
  then obtain X where "X \<subseteq> Vs E \<and> card (diff_odd_components E X) > card X"
    by blast
  then have "X \<subseteq> Vs M"
    using `perfect_matching E M`
    unfolding perfect_matching_def by auto
  have "graph_invar E" 
    using \<open>perfect_matching E M\<close> 
      perfect_matching_def by auto

  have  "matching M" 
    using \<open>perfect_matching E M\<close>
      perfect_matching_def by blast 
  have "finite M"
    by (metis Vs_def \<open>perfect_matching E M\<close> finite_UnionD perfect_matching_def)
  then have "finite (Vs M)" 
    by (metis \<open>perfect_matching E M\<close> perfect_matching_def)
  let ?comp_out  = "\<lambda> C. {e. e \<in> M \<and> (\<exists> x y. e = {x,y} \<and> y \<in> C \<and> x \<in> X)}"
  let ?QX = "(diff_odd_components E X)"

  have 2:"\<forall> e \<in> E. card e = 2" using `graph_invar E` by auto


  have "\<forall> C \<in> ?QX. (?comp_out C) \<subseteq> M"
    by blast

  have 3:"\<forall> C \<in> ?QX. card (Vs (?comp_out C)) =  sum (\<lambda> e. card e) (?comp_out C)"
    using \<open>finite (Vs M)\<close> \<open>matching M\<close> werew by fastforce


  have "\<forall> C \<in> ?QX. finite (?comp_out C)" 
    by (simp add: \<open>finite M\<close>)
  have "\<forall> C \<in> ?QX. \<forall> e \<in> (?comp_out C). card e = 2" using 2
    using \<open>perfect_matching E M\<close> perfect_matching_def by auto

  then have "\<forall> C \<in> ?QX. sum (\<lambda> e. card e) (?comp_out C) = 
      sum (\<lambda> e. 2) (?comp_out C)"  by (meson sum.cong)

  then have "\<forall> C \<in> ?QX. card (Vs (?comp_out C)) = 
      sum (\<lambda> e. 2) (?comp_out C)" using 3
    by simp 
  then have "\<forall> C \<in> ?QX. card (?comp_out C) * 2 =
    sum (\<lambda> e. 2) (?comp_out C) " by simp

  then have "\<forall> C \<in> ?QX. card (?comp_out C) * 2 =
     card ( Vs (?comp_out C))" 
    by (metis (no_types, lifting) \<open>\<forall>C\<in>diff_odd_components E X. card (Vs {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X}) = (\<Sum>e | e \<in> M \<and> (\<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X). 2)\<close>)

  have 5:"\<forall> C \<in> ?QX. \<forall> e \<in> (?comp_out C).  card (e \<inter> X) = 1"
  proof
    fix C
    assume "C \<in> ?QX"
    then have "C \<inter> X = {}" using  diff_odd_components_not_in_X[of C E X] by simp
    then show "\<forall> e \<in> (?comp_out C). card (e \<inter> X) = 1"
      using Int_commute 
      by fastforce
  qed
  have "\<forall> C \<in> ?QX. sum (\<lambda> e. card (e \<inter> X)) (?comp_out C) =
      sum (\<lambda> e. 1) (?comp_out C)" using 5 
    by simp
  then have "\<forall> C \<in> ?QX. 
    sum (\<lambda> e. card (e \<inter> X)) (?comp_out C) = card (?comp_out C)" 
    by fastforce
  have card_sum:"\<forall> C \<in> ?QX.

 card ((Vs (?comp_out C)) \<inter> X) = sum (\<lambda> e. card (e \<inter> X)) (?comp_out C)"
    using werew2 `matching M` `finite (Vs M)`
      `\<forall> C \<in> ?QX. (?comp_out C) \<subseteq> M`
    using sum.cong by fastforce


  then have "\<forall> C \<in> ?QX.
 card ((Vs (?comp_out C)) \<inter> X) =  card (?comp_out C)" using card_sum

    by (simp add: \<open>\<forall> C \<in> ?QX. 
    sum (\<lambda> e. card (e \<inter> X)) (?comp_out C) = card (?comp_out C)\<close>)

  then have "sum (\<lambda> C. card (?comp_out C)) ?QX = 
            sum (\<lambda> C. card ((Vs (?comp_out C)) \<inter> X)) ?QX"   
    by force

  have "( \<Union>C \<in>?QX. (((Vs (?comp_out C)) \<inter> X))) \<subseteq> X "
  proof
    fix x
    assume "x \<in> ( \<Union>C \<in>?QX. (((Vs (?comp_out C)) \<inter> X)))"
    then have "\<exists> C \<in> ?QX. x \<in> ((Vs (?comp_out C)) \<inter> X)"
      by blast
    then show "x \<in> X" 
      by blast
  qed
  let ?f = "(\<lambda> C. ((Vs (?comp_out C)) \<inter> X))"
  have "\<forall>C \<in> ?QX. finite ((Vs (?comp_out C)) \<inter> X)" 
    by (meson \<open>X \<subseteq> Vs M\<close> \<open>finite (Vs M)\<close> finite_Int finite_subset)
  have "finite ?QX" 
    by (metis \<open>X \<subseteq> Vs E \<and> card X < card ?QX\<close> card_eq_0_iff card_gt_0_iff less_imp_triv)



  have "\<forall> C1 \<in>?QX. \<forall> C2 \<in> ?QX.
    C1 \<noteq> C2 \<longrightarrow> ((Vs (?comp_out C1)) \<inter> X) \<inter> ((Vs (?comp_out C2)) \<inter> X) = {}"
  proof
    fix C1 
    assume "C1 \<in>?QX"
    show " \<forall> C2 \<in> ?QX.
    C1 \<noteq> C2 \<longrightarrow> ((Vs (?comp_out C1)) \<inter> X) \<inter> ((Vs (?comp_out C2)) \<inter> X) = {}"
    proof
      fix C2
      assume "C2 \<in> ?QX"
      show " C1 \<noteq> C2 \<longrightarrow> ((Vs (?comp_out C1)) \<inter> X) \<inter> ((Vs (?comp_out C2)) \<inter> X) = {}"
      proof
        assume "C1 \<noteq> C2"

        show "((Vs (?comp_out C1)) \<inter> X) \<inter> ((Vs (?comp_out C2)) \<inter> X) = {}"
        proof(rule ccontr)
          assume "((Vs (?comp_out C1)) \<inter> X) \<inter> ((Vs (?comp_out C2)) \<inter> X) \<noteq> {}"
          then have "\<exists>u. u \<in> ((Vs (?comp_out C1)) \<inter> X) \<inter> ((Vs (?comp_out C2)) \<inter> X)" by auto
          then obtain u where "u \<in> ((Vs (?comp_out C1)) \<inter> X)" "u \<in>((Vs (?comp_out C2)) \<inter> X)" 
            by auto
          then have "u \<in> X" by blast
          have "u \<in> (Vs (?comp_out C1))" 
            using \<open>u \<in> ((Vs (?comp_out C1)) \<inter> X)\<close> by blast
          have"u \<in> (Vs (?comp_out C2))"
            using \<open>u \<in> ((Vs (?comp_out C2)) \<inter> X)\<close> by blast


          then have "\<exists> e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C2 \<and> x \<in> X \<and> u \<in> e" 
            by (smt (verit) mem_Collect_eq vs_member)
          then obtain e2 where "e2 \<in> M \<and> (\<exists>x y. e2 = {x, y} \<and> y \<in> C2 \<and> x \<in> X) \<and> u \<in> e2" by auto

          then have "\<exists> e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C1 \<and> x \<in> X \<and> u \<in> e" 
            using `u \<in> (Vs (?comp_out C1)) ` by (smt (verit) mem_Collect_eq vs_member)
          then obtain e1 where "e1 \<in> M \<and> (\<exists>x y. e1 = {x, y} \<and> y \<in> C1 \<and> x \<in> X) \<and> u \<in> e1" by auto
          then have "e1 = e2" 
            by (meson \<open>matching M\<close> \<open>e2 \<in> M \<and> (\<exists>x y. e2 = {x, y} \<and> y \<in> C2 \<and> x \<in> X) \<and> u \<in> e2\<close>
                matching_unique_match)
          then show False
            using diff_component_disjoint[of E C1 X C2] 
              `graph_invar E`
              \<open>C1 \<in> diff_odd_components E X\<close>
              \<open>C1 \<noteq> C2\<close> 
              \<open>C2 \<in> diff_odd_components E X\<close>
              \<open>e1 \<in> M \<and> (\<exists>x y. e1 = {x, y} \<and> y \<in> C1 \<and> x \<in> X) \<and> u \<in> e1\<close> 
              \<open>e2 \<in> M \<and> (\<exists>x y. e2 = {x, y} \<and> y \<in> C2 \<and> x \<in> X) \<and> u \<in> e2\<close>
            by (metis  diff_odd_components_not_in_X disjoint_iff doubleton_eq_iff)
        qed
      qed
    qed
  qed
  then  have "card ( \<Union>C \<in>?QX. (((Vs (?comp_out C)) \<inter> X))) = 
    sum (\<lambda> C. card ((Vs (?comp_out C)) \<inter> X)) ?QX"
    using union_card_is_sum[of  "?QX" ?f]
      `\<forall>C \<in> ?QX. finite ((Vs (?comp_out C)) \<inter> X)`
      `finite ?QX` 
    by presburger

  then  have "sum (\<lambda> C. card ((Vs (?comp_out C)) \<inter> X)) ?QX \<le> card X" 
    by (metis (no_types, lifting) \<open>(\<Union>C\<in>diff_odd_components E X. Vs {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X} \<inter> X) \<subseteq> X\<close> \<open>X \<subseteq> Vs M\<close> \<open>finite (Vs M)\<close> card_mono finite_subset)

  then have "sum (\<lambda> C. card (?comp_out C)) ?QX \<le> card X"
    using \<open>(\<Sum>C\<in>diff_odd_components E X. card {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X}) = (\<Sum>C\<in>diff_odd_components E X. card (Vs {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X} \<inter> X))\<close> by presburger

  then have " \<forall> C \<in> ?QX. finite (?comp_out C)" 
    by (simp add: \<open>finite M\<close>) 
  have "\<forall> C \<in> ?QX. ?comp_out C \<noteq> {}"
  proof
    fix C
    assume "C \<in> ?QX" 
    show "?comp_out C \<noteq> {}"
    proof (cases "C \<in> (odd_components (graph_diff E X))")
      case True
      then have "\<exists> v \<in> Vs (graph_diff E X). connected_component (graph_diff E X) v = C \<and> odd (card C)" 
        using odd_components_def by auto
      then obtain v where "v \<in> Vs (graph_diff E X) \<and> connected_component (graph_diff E X) v = C \<and> odd (card C)"
        by auto

      show ?thesis
      proof(rule ccontr)
        assume "\<not> {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X} \<noteq> {}"
        then have " {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X} = {}" by auto
        have "\<forall>x \<in> C. \<exists> e \<in> M. \<exists> y. e = {x, y} \<and> y \<in> C"
        proof
          fix x
          assume "x\<in> C"

          then have "x \<in> Vs E" 
            using \<open>C \<in> diff_odd_components E X\<close> component_in_E by blast
          then have "x \<in> Vs M" 
            by (metis \<open>perfect_matching E M\<close> perfect_matching_def)
          then have "\<exists> e \<in> M. x \<in> e" using `perfect_matching E M` unfolding perfect_matching_def
            by (meson matching_def2)
          then obtain e where "e \<in> M" "x \<in> e" by auto
          have "graph_invar M" 
            by (metis \<open>perfect_matching E M\<close> perfect_matching_def subset_eq)
          then have " \<exists> y \<in> Vs M. e = {x, y}" 
            by (metis (full_types) \<open>e \<in> M\<close> \<open>x \<in> e\<close> edges_are_Vs empty_iff insert_commute insert_iff)
          then obtain y where "y \<in> Vs M \<and> e = {x, y}" by auto
          then have "y \<notin> X" 
            using \<open>e \<in> M\<close> \<open>x \<in> C\<close> \<open>{e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X} = {}\<close> by auto
          have "x \<notin> X" 
            using \<open>C \<in> diff_odd_components E X\<close> \<open>x \<in> C\<close> diff_odd_components_not_in_X by blast
          then have "e \<inter> X = {}" 
            using \<open>y \<in> Vs M \<and> e = {x, y}\<close> \<open>y \<notin> X\<close> by fastforce
          then have "e \<in>  (graph_diff E X)" 
            by (metis (mono_tags, lifting) \<open>e \<in> M\<close> \<open>perfect_matching E M\<close> graph_diff_def mem_Collect_eq perfect_matching_def subsetD)
          then have "connected_component (graph_diff E X) x = C" 
            by (metis \<open>v \<in> Vs (graph_diff E X) \<and> connected_component (graph_diff E X) v = C \<and> odd (card C)\<close> \<open>x \<in> C\<close> connected_components_member_eq)
          have "connected_component (graph_diff E X) y = C" 
            by (metis \<open>connected_component (graph_diff E X) x = C\<close> \<open>e \<in> graph_diff E X\<close> \<open>y \<in> Vs M \<and> e = {x, y}\<close> connected_components_member_eq in_con_comp_insert mk_disjoint_insert)
          then have "y \<in> C" 
            by (meson in_own_connected_component)
          then show " \<exists> e \<in> M. \<exists> y. e = {x, y} \<and> y \<in> C" 
            using \<open>e \<in> M\<close> \<open>y \<in> Vs M \<and> e = {x, y}\<close> by blast
        qed
        have "\<forall> e \<in> M. e \<inter> C = {} \<or> e \<inter> C = e"
        proof
          fix e
          assume "e \<in> M" 
          show "e \<inter> C = {} \<or> e \<inter> C = e" 
          proof(rule ccontr)
            assume "\<not> (e \<inter> C = {} \<or> e \<inter> C = e)"
            then have "e \<inter> C \<noteq> {} \<and> e \<inter> C \<noteq> e" 
              by auto
            then have "\<exists> x. x \<in> (e \<inter> C)" by auto
            then obtain x where "x \<in> (e \<inter> C)" by auto
            then have "x \<in> e" "x \<in> C" 
               apply simp 
              using \<open>x \<in> e \<inter> C\<close> by auto
            have "\<exists> y. y \<in> e \<and> y \<notin> C" 
              using \<open>\<not> (e \<inter> C = {} \<or> e \<inter> C = e)\<close> by blast
            show False using `\<forall>x \<in> C. \<exists> e \<in> M. \<exists> y. e = {x, y} \<and> y \<in> C` 
              by (metis \<open>matching M\<close> \<open>\<exists>y. y \<in> e \<and> y \<notin> C\<close> \<open>e \<in> M\<close> \<open>x \<in> C\<close> \<open>x \<in> e\<close> empty_iff insert_iff matching_unique_match)
          qed
        qed
        have " ((Vs M) \<inter> C) = C" 
          by (metis Int_absorb1 \<open>C \<in> diff_odd_components E X\<close> \<open>perfect_matching E M\<close> component_in_E perfect_matching_def)
        have "card ((Vs M) \<inter> C) = sum (\<lambda> e. card (e \<inter> C)) M" using werew2[of M M C] `finite M` `matching M` 
          using \<open>finite (Vs M)\<close> by blast

        have "even (sum (\<lambda> e. card (e \<inter> C)) M)" 
          by (smt (verit, best) "2" \<open>\<forall>e\<in>M. e \<inter> C = {} \<or> e \<inter> C = e\<close> \<open>perfect_matching E M\<close> dvd_sum even_numeral odd_card_imp_not_empty perfect_matching_def subset_eq)

        then have "even (card C)" 
          using \<open>Vs M \<inter> C = C\<close> \<open>card (Vs M \<inter> C) = (\<Sum>e\<in>M. card (e \<inter> C))\<close> by presburger
        show False 
          using \<open>even (card C)\<close> \<open>v \<in> Vs (graph_diff E X) \<and> connected_component (graph_diff E X) v = C \<and> odd (card C)\<close> by blast
      qed
    next
      case False
      then have "C \<in> (singleton_in_diff E X)"
        by (metis UnE \<open>C \<in> diff_odd_components E X\<close> diff_odd_components_def)
      then have " \<exists> v. C = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)"
        unfolding singleton_in_diff_def 
        by blast
      then obtain v where " C = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)" by auto
      then have "v \<in> Vs M" 
        by (metis \<open>perfect_matching E M\<close> perfect_matching_def)
      then have "\<exists> e \<in> M. v \<in> e" 
        by (meson vs_member_elim)
      then obtain e where " e \<in> M \<and> v \<in> e" 
        by (meson \<open>C = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)\<close> vs_member_elim)
      then have "e \<in> E" 
        using \<open>perfect_matching E M\<close> perfect_matching_def by blast
      then have "e \<notin> (graph_diff E X)" 
        using \<open>C = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)\<close> 
        using \<open>e \<in> M \<and> v \<in> e\<close> by blast
      then have "e \<inter> X \<noteq> {}" 
        by (simp add: \<open>e \<in> E\<close> graph_diff_def)
      then have "\<exists> y. y \<in> e \<and> y \<in> X" by auto
      then obtain y where "y \<in> e \<and> y \<in> X" by auto
      have "v \<noteq> y" 
        using \<open>C = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)\<close> \<open>y \<in> e \<and> y \<in> X\<close> by fastforce
      then have "e = {v, y}" using `y \<in> e \<and> y \<in> X` `e \<in> M \<and> v \<in> e` `graph_invar E` `e \<in> E`
        by fastforce 
      have "v\<in> C" 
        by (simp add: \<open>C = {v} \<and> v \<in> Vs E \<and> v \<notin> X \<and> v \<notin> Vs (graph_diff E X)\<close>)
      then have " \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X" using `y \<in> e \<and> y \<in> X`   using \<open>e = {v, y}\<close> by blast
      then have "e \<in> ?comp_out C" 
        by (simp add: \<open>e \<in> M \<and> v \<in> e\<close>)

      then show ?thesis 
        by blast
    qed
  qed

  then have "\<forall> C \<in> ?QX. card( ?comp_out C) > 0" 
    by (simp add: \<open>\<forall>C\<in>diff_odd_components E X. {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X} \<noteq> {}\<close> \<open>\<forall>C\<in>diff_odd_components E X. finite {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X}\<close> card_gt_0_iff)
  then have "\<forall> C \<in> ?QX. card( ?comp_out C) \<ge> 1"
    by (simp add: Suc_leI)
  then have "sum (\<lambda> C. card (?comp_out C)) ?QX \<ge> 
    card ?QX"
    using sum_mono by fastforce
  then have " card X \<ge>  card ?QX"  
    using \<open>(\<Sum>C\<in>diff_odd_components E X. card {e \<in> M. \<exists>x y. e = {x, y} \<and> y \<in> C \<and> x \<in> X}) \<le> card X\<close> order_trans by blast

  then show False 
    using \<open>X \<subseteq> Vs E \<and> card X < card ?QX\<close> not_less by blast
qed

lemma graph_component_edges_partition:
  assumes "graph_invar E"
  shows "\<Union> (components_edges E) = E"
  unfolding components_edges_def
proof(safe)
  fix e
  assume "e \<in> E" 
  then obtain x y where "e = {x, y}" using assms 
    by meson
  then obtain C where "e \<subseteq> C" "C \<in> connected_components E"
    by (metis \<open>e \<in> E\<close> edge_in_component) 
  moreover then have "e \<in> component_edges E C" 
    using \<open>e \<in> E\<close> component_edges_def `e = {x, y}`
    by fastforce
  show "e  \<in> \<Union> {component_edges E C |C.  C \<in> connected_components E}" 

    using \<open>e \<in> component_edges E C\<close> calculation(2) by blast
qed (auto simp add: component_edges_def)

lemma graph_component_partition:
  assumes "graph_invar E"
  shows "\<Union> (connected_components E) = Vs E" 
  unfolding connected_components_def
proof(safe)

  { fix x v
    assume " x \<in> connected_component E v" "v \<in> Vs E"
    then show "x \<in> Vs E" 
      by (metis in_connected_component_in_edges)}

  fix y
  assume "y \<in> Vs E"
  show "y \<in> \<Union> {connected_component E v |v. v \<in> Vs E}" 
    using \<open>y \<in> Vs E\<close> in_own_connected_component by fastforce
qed


lemma sum_card_connected_components:
  assumes "graph_invar E"
  shows "sum (\<lambda> x. card x) (connected_components E) = card (Vs E)"
proof -
  let ?Cs = "connected_components E"
  have "finite ?Cs"  
    by (simp add: assms finite_con_comps)
  moreover  have "\<forall>C \<in> ?Cs. finite C" 
    by (meson assms connected_component_subs_Vs finite_subset)
  moreover have "\<forall> C1 \<in> ?Cs. \<forall> C2 \<in> ?Cs. C1 \<noteq> C2 \<longrightarrow>  C1 \<inter>  C2 = {}"
    by (simp add: connected_components_disj)
  ultimately have "sum (\<lambda> C. card C) ?Cs = card (\<Union>C\<in>?Cs. C)"
    using union_card_is_sum[of ?Cs "(\<lambda> C. C)"] by blast
  then show ?thesis using graph_component_partition[of E] assms by auto
qed

lemma components_is_union_even_and_odd:
  assumes "graph_invar E"
  shows "connected_components E = odd_components E \<union> even_components E"
  unfolding connected_components_def odd_components_def even_components_def
  apply safe
  by auto


lemma components_parity_is_odd_components_parity:
  assumes "graph_invar E"
  shows "even (sum card (connected_components E)) = even (card (odd_components E))"
proof -
  let ?Cs = " (connected_components E)"
  have "finite ?Cs"  
    by (simp add: assms finite_con_comps)
  then have "even (sum card (connected_components E)) = even (card {C \<in> ?Cs. odd (card C)})"
    using Parity.semiring_parity_class.even_sum_iff[of ?Cs card] by auto
  moreover have "{C \<in> ?Cs. odd (card C)} = odd_components E" unfolding connected_components_def
      odd_components_def 
    by blast
  ultimately show ?thesis
    by presburger 
qed


lemma odd_components_eq_modulo_cardinality:
  assumes "graph_invar E"
  shows "even (card (odd_components E)) = even (card (Vs E))"
  using components_parity_is_odd_components_parity[of E] 
    sum_card_connected_components[of E]
    assms
  by auto


lemma diff_is_union_elements:
  assumes "graph_invar E"
  assumes "X \<subseteq> Vs E"
  shows "Vs (graph_diff E X) \<union> Vs (singleton_in_diff E X) \<union> X = Vs E"
proof(safe)
  {
    fix x
    assume "x \<in> Vs (graph_diff E X)"
    then show "x \<in> Vs E" 
      by (meson Vs_subset graph_diff_subset subsetD)
  }
  {
    fix x
    assume " x \<in> Vs (singleton_in_diff E X)"
    then show "x \<in> Vs E" unfolding singleton_in_diff_def
      using vs_transport by fastforce
  }
  {
    fix x
    assume "x \<in> X"
    then show "x \<in> Vs E" using assms(2) by auto
  }
  fix x
  assume " x \<in> Vs E" "x \<notin> X" "x \<notin> Vs (singleton_in_diff E X)"
  then have "\<not> (x \<in> Vs E \<and> x \<notin> X \<and> x \<notin> Vs (graph_diff E X))" 
    unfolding singleton_in_diff_def 
    by blast


  then show " x \<in> Vs (graph_diff E X)" unfolding graph_diff_def

    using \<open>x \<in> Vs E\<close> \<open>x \<notin> X\<close> by fastforce
qed

lemma diff_disjoint_elements:
  assumes "graph_invar E"
  assumes "X \<subseteq> Vs E"
  shows "Vs (graph_diff E X) \<inter> Vs (singleton_in_diff E X) = {}" 
    "Vs (graph_diff E X) \<inter> X = {}"
    "Vs (singleton_in_diff E X) \<inter> X = {}"
proof(safe)
  {
    fix x
    assume " x \<in> Vs (graph_diff E X)"
      " x \<in> Vs (singleton_in_diff E X)"
    then show "x \<in> {}" unfolding singleton_in_diff_def 
      by (smt (verit) mem_Collect_eq singletonD vs_member)
  }
  {
    fix x
    assume "x \<in> Vs (graph_diff E X)"  "x \<in> X"
    then have "x \<notin> X" unfolding graph_diff_def
      by (smt (verit, best) disjoint_iff_not_equal mem_Collect_eq vs_member)
    then show "x \<in> {}" using `x \<in> X` by auto
  }

  fix x
  assume "x \<in> Vs (singleton_in_diff E X)" "x \<in> X"
  then show "x \<in> {}" unfolding singleton_in_diff_def
    by (smt (verit) mem_Collect_eq singletonD vs_member)
qed

lemma diff_card_is_sum_elements:
  assumes "graph_invar E"
  assumes "X \<subseteq> Vs E"
  shows "card (Vs (graph_diff E X)) + card (Vs (singleton_in_diff E X)) +  card X = card (Vs E)"
  using diff_is_union_elements[of E X] diff_disjoint_elements[of E X]
  by (smt (z3) Int_Un_distrib2 assms(1) assms(2) card_Un_disjoint finite_Un sup_bot_right)


value "even (nat (abs (-1)))"

lemma singleton_set_card_eq_vertices:
  assumes "graph_invar E"
  assumes "X \<subseteq> Vs E"
  shows "card (Vs (singleton_in_diff E X)) = card (singleton_in_diff E X)"
proof -
  let ?A = "(singleton_in_diff E X)"
  have "finite ?A" 
    by (metis Vs_def assms(1) assms(2) diff_is_union_elements finite_Un finite_UnionD)
  moreover  have "\<forall>C \<in> ?A. finite C" 
    by (metis Un_iff assms(1) component_in_E diff_odd_components_def finite_subset)
  moreover have "\<forall> C1 \<in> ?A. \<forall> C2 \<in> ?A. C1 \<noteq> C2 \<longrightarrow> C1 \<inter> C2 = {}" 
    by (smt (verit, best) Int_def empty_Collect_eq mem_Collect_eq singletonD singleton_in_diff_def)

  ultimately  have "sum card ?A = card (Vs ?A)" using assms 
    by (simp add: Vs_def card_Union_disjoint disjnt_def pairwise_def)

  have "\<forall>C \<in> ?A. card C = 1" unfolding singleton_in_diff_def
    using is_singleton_altdef by blast
  then have "sum card ?A = card ?A" 
    by force
  then show ?thesis 
    using \<open>sum card (singleton_in_diff E X) = card (Vs (singleton_in_diff E X))\<close> by presburger
qed

lemma diff_odd_component_parity':
  assumes "graph_invar E"
  assumes "X \<subseteq> Vs E"
  assumes  "card X \<le> card (diff_odd_components E X)"
  shows "even (card (diff_odd_components E X) - card X )  = even (card (Vs E))"
proof -
  let ?odd = "(odd_components (graph_diff E X))"
  let ?singl = "(singleton_in_diff E X)"
  let ?EwoX = "(graph_diff E X)"
  let ?allOdd = "diff_odd_components E X"

  have "finite X" 
    using assms(1) assms(2) finite_subset by auto
  then have "finite ?allOdd" unfolding diff_odd_components_def 
    by (smt (verit, ccfv_threshold) Vs_def assms(1) assms(2) components_is_union_even_and_odd diff_is_union_elements finite_Un finite_UnionD finite_con_comps graph_diff_subset subset_eq)
  have "finite ?odd" 
    by (metis \<open>finite ?allOdd\<close> diff_odd_components_def finite_Un)

  have "graph_invar ?EwoX" 
    by (metis (no_types, lifting) assms(1) assms(2) diff_is_union_elements finite_Un graph_diff_subset insert_subset mk_disjoint_insert)

  have "?odd \<inter> ?singl = {}"
    unfolding odd_components_def singleton_in_diff_def 
    using connected_component_subset 
    by fastforce
  then have "card ?allOdd =  card ?odd + card ?singl" 
    unfolding diff_odd_components_def 
    by (metis \<open>finite ?allOdd\<close> card_Un_disjoint diff_odd_components_def finite_Un)
  have "even (card ?allOdd - card X) = even ( card ?allOdd + card X)"
    by (meson assms(3) even_diff_nat not_less)
  also have "\<dots> =  even (card X + card ?odd + card ?singl)"
    using \<open>card ?allOdd = card ?odd + card ?singl\<close> by presburger
  also have "\<dots> = even (card X + card (Vs ?EwoX) + card ?singl)" 
    using odd_components_eq_modulo_cardinality[of "?EwoX"] `graph_invar ?EwoX`
    by auto
  also have "\<dots> = even (card (Vs ?EwoX) + card (Vs ?singl) + card X)" 
    using singleton_set_card_eq_vertices[of E X] assms by presburger
  also have "\<dots>  = even (card (Vs E))"
    using diff_card_is_sum_elements[of E X] assms(1) assms(2) 
    by presburger
  finally show ?thesis by auto
qed

lemma diff_odd_component_parity:
  assumes "graph_invar E"
  assumes "X \<subseteq> Vs E"
  assumes  "card X \<ge> card (diff_odd_components E X)"
  shows "even (card X - card (diff_odd_components E X)) = even (card (Vs E))"
proof -
  let ?odd = "(odd_components (graph_diff E X))"
  let ?singl = "(singleton_in_diff E X)"
  let ?EwoX = "(graph_diff E X)"
  let ?allOdd = "diff_odd_components E X"

  have "finite X" 
    using assms(1) assms(2) finite_subset by auto
  then have "finite ?allOdd" unfolding diff_odd_components_def 
    by (smt (verit, ccfv_threshold) Vs_def assms(1) assms(2) components_is_union_even_and_odd diff_is_union_elements finite_Un finite_UnionD finite_con_comps graph_diff_subset subset_eq)
  have "finite ?odd" 
    by (metis \<open>finite ?allOdd\<close> diff_odd_components_def finite_Un)

  have "graph_invar ?EwoX" 
    by (metis (no_types, lifting) assms(1) assms(2) diff_is_union_elements finite_Un graph_diff_subset insert_subset mk_disjoint_insert)

  have "?odd \<inter> ?singl = {}"
    unfolding odd_components_def singleton_in_diff_def 
    using connected_component_subset 
    by fastforce
  then have "card ?allOdd =  card ?odd + card ?singl" 
    unfolding diff_odd_components_def 
    by (metis \<open>finite ?allOdd\<close> card_Un_disjoint diff_odd_components_def finite_Un)
  have "even (card X - card ?allOdd) = even (card X + card ?allOdd)"
    by (meson assms(3) even_diff_nat not_less)
  also have "\<dots> =  even (card X + card ?odd + card ?singl)"
    using \<open>card ?allOdd = card ?odd + card ?singl\<close> by presburger
  also have "\<dots> = even (card X + card (Vs ?EwoX) + card ?singl)" 
    using odd_components_eq_modulo_cardinality[of "?EwoX"] `graph_invar ?EwoX`
    by auto
  also have "\<dots> = even (card (Vs ?EwoX) + card (Vs ?singl) + card X)" 
    using singleton_set_card_eq_vertices[of E X] assms by presburger
  also have "\<dots>  = even (card (Vs E))"
    using diff_card_is_sum_elements[of E X] assms(1) assms(2) 
    by presburger
  finally show ?thesis by auto
qed

lemma defvd:
  assumes "graph_invar E"
  assumes "path E p"
  assumes "C \<in> connected_components E"
  assumes "hd p \<in> C"
  assumes "(component_edges E C) \<noteq> {}" 
  shows "path (component_edges E C) p" using assms(2) assms(4) 
proof(induct p rule:list.induct)
  case Nil
  then show ?case 
    by simp
next
  case (Cons x1 x2)
  have "path E (x1 # x2)" 
    by (simp add: Cons.prems(1))
  then have "path E x2" 
    by (metis list.sel(3) tl_path_is_path)
  have "x1 \<in> C" 
    using Cons.prems(2) by auto
  then have "C =  connected_component E x1"
    by (simp add: assms(3) connected_components_closed')

  have "x1 \<in> Vs E"
    by (meson \<open>x1 \<in> C\<close> assms(3) connected_comp_verts_in_verts)
  then have "\<exists> e \<in> E.  x1 \<in> e" 
    by (meson vs_member_elim)
  then obtain e where "e \<in> E \<and> x1 \<in> e" by auto
  then have "\<exists>y. e = {x1, y}"
    using assms(1) by auto 
  then obtain y where " e = {x1, y}" by auto
  then have "y \<in> C" 
    by (metis \<open>C = connected_component E x1\<close> \<open>e \<in> E \<and> x1 \<in> e\<close> in_con_comp_insert insert_Diff)

  then have "e \<subseteq> C" using `x1 \<in> C` 
    by (simp add: \<open>e = {x1, y}\<close>)
  then have "e \<in> (component_edges E C)" unfolding component_edges_def
    using \<open>e = {x1, y}\<close> \<open>e \<in> E \<and> x1 \<in> e\<close> by blast
  then have "x1 \<in> Vs (component_edges E C)" 
    by (simp add: \<open>e = {x1, y}\<close> edges_are_Vs)
  show ?case
  proof(cases "x2 = []")
    case True

    have "path (component_edges E C) [x1]" 
      by (simp add: \<open>x1 \<in> Vs (component_edges E C)\<close>)
    then show ?thesis
      by (simp add: True)
  next
    case False
    have "{x1, hd x2} = hd (edges_of_path (x1 # x2))" 
      by (metis False edges_of_path.simps(3) list.exhaust list.sel(1))
    then have "{x1, hd x2} \<in> E"

      by (metis Cons.prems(1) False equals0D last_in_edge list.set(1) list.set_sel(1) path_ball_edges)
    then have "walk_betw E x1 [x1, hd x2] (hd x2)" 
      by (simp add: edges_are_walks)
    then have "hd x2 \<in> C" 
      by (meson \<open>x1 \<in> C\<close> assms(3) in_con_compI)
    then have "{x1, hd x2} \<subseteq> C" 
      using \<open>e = {x1, y}\<close> \<open>e \<subseteq> C\<close> by blast
    then have "{x1, hd x2} \<in> (component_edges E C)"
      unfolding component_edges_def using `{x1, hd x2} \<in> E`  
      by blast

    then have "path (component_edges E C) x2" using `hd x2 \<in> C`
      by (simp add: Cons.hyps \<open>path E x2\<close>)

    then show ?thesis 
      by (metis False \<open>{x1, hd x2} \<in> component_edges E C\<close> hd_Cons_tl path_2)
  qed
qed

lemma inj_cardinality:
  assumes "finite A"
  assumes "finite B"
  assumes "\<forall>a1 \<in>A.\<forall>a2\<in>A. a1 \<noteq> a2 \<longrightarrow> a1 \<inter> a2 = {}"
  assumes "\<forall>a\<in>A. \<exists>b\<in>B. b \<in> a"
  shows "card A \<le> card B" using assms(1) assms(2) assms(3) assms(4)
proof(induct A arbitrary: B)
  case empty
  then show ?case by auto
next
  case (insert x F)
  have "\<forall>a1\<in>F. \<forall>a2\<in>F. a1 \<noteq> a2 \<longrightarrow> a1 \<inter> a2 = {}"
    
    by (simp add: insert.prems(2))
   have "\<exists>b\<in>B. b \<in> x" 
     by (simp add: insert.prems(3))
   then obtain b where "b \<in> B \<and> b \<in> x" by auto
   then have " \<forall>a\<in>F. b \<notin> a" 
     using UnionI insert.hyps(2) insert.prems(2) by auto
   then have " \<forall>a\<in>F. \<exists>b1\<in>B. b1 \<in> a \<and> b1 \<noteq> b" 
     using insert.prems(3)
     by (metis insert_iff)
   then have "\<forall>a\<in>F. \<exists>b1\<in>B-{b}. b1 \<in> a" 
     by (metis \<open>b \<in> B \<and> b \<in> x\<close> insertE insert_Diff)
   have "finite (B - {b})" 
     using insert.prems(1) by blast
   then  have "card F \<le> card (B - {b})" 
    using \<open>\<forall>a1\<in>F. \<forall>a2\<in>F. a1 \<noteq> a2 \<longrightarrow> a1 \<inter> a2 = {}\<close> \<open>\<forall>a\<in>F. \<exists>b1\<in>B - {b}. b1 \<in> a\<close> insert.hyps(3) by presburger 
  then have "card F \<le> card B - 1" 
    by (metis One_nat_def \<open>b \<in> B \<and> b \<in> x\<close> card.empty card.infinite card.insert card_Diff_singleton card_insert_le diff_is_0_eq' emptyE finite.emptyI infinite_remove)
  then have "card F + 1 \<le> card B" using assms
 proof -
  show ?thesis
    by (metis (no_types) One_nat_def Suc_leI \<open>b \<in> B \<and> b \<in> x\<close> \<open>card F \<le> card B - 1\<close> add_Suc_right add_leE card_Diff1_less insert.prems(1) nat_arith.rule0 ordered_cancel_comm_monoid_diff_class.le_diff_conv2)
qed
    
    then have "card (insert x F) \<le> card B" 
      by (simp add: insert.hyps(1) insert.hyps(2))
  then show ?case by auto
qed


lemma yfsdf:
  assumes "finite A"
  assumes "finite B"
  assumes "\<forall>a1 \<in>A.\<forall>a2\<in>A. a1 \<noteq> a2 \<longrightarrow> a1 \<inter> a2 = {}"
  assumes "\<forall>a\<in>A. \<exists>b\<in>B. b \<in> a"
  shows "\<exists>C\<subseteq>B . \<forall>a\<in>A. \<exists>b\<in>C. b \<in> a \<and> card A = card C" using assms(1) assms(2) assms(3) assms(4)
proof(induct A arbitrary: B)
case empty
then show ?case by auto
next
  case (insert x F)
  have "\<forall>a1\<in>F. \<forall>a2\<in>F. a1 \<noteq> a2 \<longrightarrow> a1 \<inter> a2 = {}"
    
    by (simp add: insert.prems(2))
   have "\<exists>b\<in>B. b \<in> x" 
     by (simp add: insert.prems(3))
   then obtain b where "b \<in> B \<and> b \<in> x" by auto
   then have " \<forall>a\<in>F. b \<notin> a" 
     using UnionI insert.hyps(2) insert.prems(2) by auto
   then have " \<forall>a\<in>F. \<exists>b1\<in>B. b1 \<in> a \<and> b1 \<noteq> b" 
     using insert.prems(3)
     by (metis insert_iff)
   then have "\<forall>a\<in>F. \<exists>b1\<in>B-{b}. b1 \<in> a" 
     by (metis \<open>b \<in> B \<and> b \<in> x\<close> insertE insert_Diff)
   have "finite (B - {b})" 
     using insert.prems(1) by blast
   have "\<exists>C\<subseteq>(B - {b}). \<forall>a\<in>F. \<exists>b\<in>C. b \<in> a  \<and> card F = card C" 
     using \<open>\<forall>a1\<in>F. \<forall>a2\<in>F. a1 \<noteq> a2 \<longrightarrow> a1 \<inter> a2 = {}\<close> \<open>\<forall>a\<in>F. \<exists>b1\<in>B - {b}. b1 \<in> a\<close> \<open>finite (B - {b})\<close> insert.hyps(3) by presburger
   then  obtain C where "C\<subseteq>(B - {b}) \<and> (\<forall>a\<in>F. \<exists>b\<in>C. b \<in> a)  \<and> card F = card C"
     
     by (metis card.empty empty_subsetI finite_has_maximal insert.hyps(1))
   then have "(C \<union> {b}) \<subseteq> B" 
     using \<open>b \<in> B \<and> b \<in> x\<close> by blast
   have "\<forall>a\<in>insert x F. \<exists>b\<in> (C \<union> {b}). b \<in> a" 
     using \<open>C \<subseteq> B - {b} \<and> (\<forall>a\<in>F. \<exists>b\<in>C. b \<in> a) \<and> card F = card C\<close> \<open>b \<in> B \<and> b \<in> x\<close> by blast
   have "card F = card C" 
     by (simp add: \<open>C \<subseteq> B - {b} \<and> (\<forall>a\<in>F. \<exists>b\<in>C. b \<in> a) \<and> card F = card C\<close>)
   
   have "card (insert x F) = card C + 1" 
     by (simp add: \<open>card F = card C\<close> insert.hyps(1) insert.hyps(2))
   
   then show ?case 
     by (metis Un_insert_right \<open>C \<subseteq> B - {b} \<and> (\<forall>a\<in>F. \<exists>b\<in>C. b \<in> a) \<and> card F = card C\<close> \<open>C \<union> {b} \<subseteq> B\<close> \<open>\<forall>a\<in>insert x F. \<exists>b\<in>C \<union> {b}. b \<in> a\<close> \<open>finite (B - {b})\<close> boolean_algebra_cancel.sup0 card.insert finite_subset insert.hyps(1) insert.hyps(2) subset_Diff_insert)
 qed

lemma yfsdf1:
  assumes "finite A"
  assumes "finite B"
  assumes "\<forall>a1 \<in>A.\<forall>a2\<in>A. a1 \<noteq> a2 \<longrightarrow> a1 \<inter> a2 = {}"
  assumes "\<forall>a\<in>A. \<exists>b\<in>B. b \<in> a"
  shows "\<exists>C\<subseteq>B . \<forall>a\<in>A. \<exists>!b\<in>C. b \<in> a"
proof(rule ccontr)
  assume "\<not> (\<exists>C\<subseteq>B. \<forall>a\<in>A. \<exists>!b. b \<in> C \<and> b \<in> a)"
  then have "\<forall>C\<subseteq>B. \<exists>a\<in>A. \<not> (\<exists>!b. b \<in> C \<and> b \<in> a)" by auto
  have "\<exists>C\<subseteq>B . \<forall>a\<in>A. \<exists>b\<in>C. b \<in> a \<and> card A = card C" using assms yfsdf[of A B]
    by auto
  then obtain C where "C\<subseteq>B \<and> ( \<forall>a\<in>A. \<exists>b\<in>C. b \<in> a) \<and> card A = card C" 
    by (meson \<open>\<not> (\<exists>C\<subseteq>B. \<forall>a\<in>A. \<exists>!b. b \<in> C \<and> b \<in> a)\<close>)


  then have "\<exists>a\<in>A. \<not> (\<exists>!b. b \<in> C \<and> b \<in> a)" 
    using \<open>\<not> (\<exists>C\<subseteq>B. \<forall>a\<in>A. \<exists>!b. b \<in> C \<and> b \<in> a)\<close> by auto
  then obtain a where "a\<in>A \<and> \<not> (\<exists>!b. b \<in> C \<and> b \<in> a)" 
    by force
  have "\<exists>b. b \<in> C \<and> b \<in> a" 
    by (meson \<open>C \<subseteq> B \<and> (\<forall>a\<in>A. \<exists>b\<in>C. b \<in> a) \<and> card A = card C\<close> \<open>a \<in> A \<and> (\<nexists>!b. b \<in> C \<and> b \<in> a)\<close>)





lemma tutte2:
  assumes "graph_invar E"
  assumes "tutte_condition E"
  shows "\<exists>M. perfect_matching E M" 
proof(cases "card (Vs E) \<le> 2")
  case True
  then show ?thesis
  proof(cases "card (Vs E) = 2")
    case True
    then obtain x y where "x \<in> Vs E \<and> y \<in> Vs E \<and> x \<noteq> y" 
      by (meson card_2_iff')
    then have "{x, y} =  Vs E" using True 
      by (smt (verit, best) card_2_iff doubleton_eq_iff insert_absorb insert_iff)
    have "\<forall> e \<in> E. e = {x, y}"
    proof
      fix e
      assume "e \<in> E"
      show "e = {x, y}"
      proof(rule ccontr)
        assume " e \<noteq> {x, y}"
        then obtain u where "u \<in> e \<and> (u \<noteq> x \<and> u \<noteq> y)" 
          by (metis \<open>e \<in> E\<close> assms(1) doubleton_eq_iff insertI1 insert_subset subset_insertI)
        then have "u \<in> Vs E"
          using \<open>e \<in> E\<close> by blast
        then show False 
          using \<open>u \<in> e \<and> u \<noteq> x \<and> u \<noteq> y\<close> \<open>{x, y} = Vs E\<close> by blast
      qed
    qed
    then have "E = {{x, y}}" 
      using \<open>x \<in> Vs E \<and> y \<in> Vs E \<and> x \<noteq> y\<close> vs_member by fastforce
    then have "matching E" 
      using matching_def by fastforce
    moreover have "E \<subseteq> E" by auto
    ultimately have "perfect_matching E E" unfolding perfect_matching_def
      using assms(1) by blast
    then show ?thesis by auto
  next
    case False
    then show ?thesis
    proof(cases "card (Vs E) = 1")
      case True
      then show ?thesis 
        by (metis One_nat_def assms(1) card_Suc_eq card_mono connected_component_not_singleton connected_component_subset not_less singletonI)
    next
      case False
      then have "card (Vs E) = 0" using `card (Vs E) \<le> 2` `card (Vs E) \<noteq> 2` 
        by (metis One_nat_def Suc_1 bot_nat_0.extremum_uniqueI not_less_eq_eq verit_la_disequality)
      then show ?thesis
        by (metis assms(1) card_eq_0_iff equals0D matching_def2 order_refl perfect_matching_def)
    qed
  qed
next
  case False
  then show ?thesis using assms
  proof(induction "card (Vs E)" arbitrary: E rule: nat_less_induct) 
    case 1
    have "even (card (Vs E))"
    proof(rule ccontr)
      assume "odd (card (Vs E))"
      have " {} \<subseteq> E" by auto
      then have "card (diff_odd_components E {}) \<le> card {}" 
        by (metis "1.prems"(3) bot.extremum card.empty tutte_condition_def)
      then have "card (diff_odd_components E {}) = 0" by simp
      have "graph_diff E {} = E" 
        by (simp add: graph_diff_def)
      then have "(singleton_in_diff E {}) = {}" 
        unfolding singleton_in_diff_def 
        by simp
      then have "diff_odd_components E {} = odd_components E"
        unfolding diff_odd_components_def using `graph_diff E {} = E`
        by simp
      have "card (odd_components E) \<ge> 1" using `odd (card (Vs E))` 
        by (metis "1.prems"(2) \<open>card (diff_odd_components E {}) = 0\<close> \<open>diff_odd_components E {} = odd_components E\<close> card.empty odd_card_imp_not_empty odd_components_eq_modulo_cardinality)
      then show False
        using \<open>card (diff_odd_components E {}) = 0\<close> \<open>diff_odd_components E {} = odd_components E\<close> by force
    qed
    have "\<forall>x \<in> (Vs E). card {x} \<ge> card (diff_odd_components E {x})"
      using "1.prems"(3) 
      by (meson bot.extremum insert_subsetI tutte_condition_def)
    then  have "\<forall>x \<in> (Vs E). even (card {x} - card (diff_odd_components E {x}))" 
      using `even (card (Vs E))` diff_odd_component_parity
      by (metis "1.prems"(2) bot.extremum insert_subsetI)
    then have "\<forall>x \<in> (Vs E).card (diff_odd_components E {x}) = 1"
      by (metis One_nat_def Suc_leI \<open>\<forall>x\<in>Vs E. card (diff_odd_components E {x}) \<le> card {x}\<close> antisym_conv card.empty card.insert dvd_diffD empty_iff finite.emptyI not_less odd_card_imp_not_empty odd_one zero_order(2))
    then have "\<forall>x \<in> (Vs E). barrier E {x}"
      by (metis barrier_def insert_not_empty is_singleton_altdef is_singleton_def)
    then have "\<exists> X \<subseteq> Vs E. barrier E X" 
      by (metis "1.prems"(1) bot.extremum card.empty equals0I  insert_subsetI zero_order(2))
    let ?B = "{X. X \<subseteq> Vs E \<and> barrier E X}"
    have "finite (Vs E)" 
      by (simp add: "1.prems"(2))
    then  have "finite ?B" by auto
    then  have "\<exists>X \<in> ?B. \<forall> Y \<in> ?B. Y \<noteq> X \<longrightarrow> \<not> (X \<subseteq> Y)" 
      by (metis (no_types, lifting) \<open>\<exists>X\<subseteq>Vs E. barrier E X\<close> empty_iff finite_has_maximal mem_Collect_eq)
    then obtain X where X_max:"X \<in> ?B \<and> ( \<forall> Y \<in> ?B. Y \<noteq> X \<longrightarrow> \<not> (X \<subseteq> Y))" by meson
    then have " X \<subseteq> Vs E \<and> barrier E X" by auto
    then have "card (diff_odd_components E X) = card X" unfolding barrier_def by auto
    have "even_components (graph_diff E X) = {}"
    proof(rule ccontr)
      assume " even_components (graph_diff E X) \<noteq> {}"
      then obtain C where "C \<in>  even_components (graph_diff E X)" by auto
      then have "\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C"
        by (simp add:  even_components_def)
      then obtain v where "v \<in> C"
        by (smt (verit) even_components_def in_own_connected_component mem_Collect_eq)
      then have comp_C:"connected_component (graph_diff E X) v = C"
        by (metis \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> connected_components_member_eq)


      have "singleton_in_diff E X \<subseteq> singleton_in_diff E (X \<union> {v})"
      proof
        fix xs
        assume "xs \<in> singleton_in_diff E X"

        then have "\<exists>x. xs = {x} \<and> x \<in> Vs E \<and> x \<notin> X \<and> x \<notin> Vs (graph_diff E X)" 
          unfolding singleton_in_diff_def by auto
        then obtain x where " xs = {x} \<and> x \<in> Vs E \<and> x \<notin> X \<and> x \<notin> Vs (graph_diff E X)" 
          by presburger
        then have "x \<notin> X \<union> {v}" 
          by (metis UnE \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> in_connected_component_in_edges singletonD)
        have "x \<notin> Vs (graph_diff E X)" 
          by (simp add: \<open>xs = {x} \<and> x \<in> Vs E \<and> x \<notin> X \<and> x \<notin> Vs (graph_diff E X)\<close>)
        then have "x \<notin> Vs (graph_diff E (X \<union> {v}))" unfolding graph_diff_def
          by (simp add: vs_member)
        then have "{x} \<in> singleton_in_diff E (X \<union> {v})" unfolding
            singleton_in_diff_def
          using \<open>x \<notin> X \<union> {v}\<close> \<open>xs = {x} \<and> x \<in> Vs E \<and> x \<notin> X \<and> x \<notin> Vs (graph_diff E X)\<close> by blast
        then show "xs \<in> singleton_in_diff E (X \<union> {v})" 
          by (simp add: \<open>xs = {x} \<and> x \<in> Vs E \<and> x \<notin> X \<and> x \<notin> Vs (graph_diff E X)\<close>)
      qed


      have "graph_diff E (X\<union>{v}) \<subseteq> graph_diff E X" unfolding graph_diff_def
        by (simp add: Collect_mono)






      have "odd_components (graph_diff E X) \<subseteq> odd_components (graph_diff E (X \<union> {v}))"
      proof
        fix C'
        assume "C' \<in> odd_components (graph_diff E X)"
        then have "\<exists>x \<in> Vs (graph_diff E X). 
      connected_component (graph_diff E X) x = C' \<and> odd (card C')"
          unfolding odd_components_def
          by blast
        then  obtain x where odd_x:"x \<in> Vs (graph_diff E X) \<and>
                          connected_component (graph_diff E X) x = C' \<and> 
                            odd (card C')" by auto


        then have "x \<notin> C" 
          by (smt (verit) \<open>C \<in> even_components (graph_diff E X)\<close> connected_components_member_eq even_components_def mem_Collect_eq)
        then have "x \<noteq> v" 
          using \<open>v \<in> C\<close> by blast
        then have "\<exists>e \<in> (graph_diff E X). x \<in> e" 
          by (meson odd_x vs_member_elim)
        then obtain e where "e \<in> (graph_diff E X) \<and> x \<in> e" by auto
        then have "e \<subseteq> C'" 
          by (smt (z3) "1.prems"(2) empty_subsetI graph_diff_subset in_con_comp_insert in_own_connected_component insertE insert_Diff insert_commute insert_subset odd_x singletonD)

        then have "e \<in> component_edges (graph_diff E X) C'"
          unfolding component_edges_def 
          by (smt (verit) "1.prems"(2) \<open>e \<in> graph_diff E X \<and> x \<in> e\<close> graph_diff_subset insert_Diff insert_subset mem_Collect_eq) 
        have "\<forall>z \<in> C'. z \<in>   Vs (graph_diff E (X \<union> {v}))"
        proof
          fix z
          assume "z\<in> C'" 
          have "z\<noteq>v"
            by (metis \<open>x \<notin> C\<close> \<open>z \<in> C'\<close> comp_C connected_components_member_sym odd_x)
          then have "z \<notin> C" 
            by (metis \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>x \<notin> C\<close> \<open>z \<in> C'\<close> connected_components_member_eq in_own_connected_component odd_x)

          have "\<exists>e \<in> E. e \<inter> X = {} \<and> z \<in> e" 
            by (smt (z3) \<open>\<And>thesis. (\<And>x. x \<in> Vs (graph_diff E X) \<and> connected_component (graph_diff E X) x = C' \<and> odd (card C') \<Longrightarrow> thesis) \<Longrightarrow> thesis\<close> \<open>z \<in> C'\<close> graph_diff_def in_connected_component_in_edges mem_Collect_eq vs_member)
          then obtain e where "e\<in>E \<and>  e \<inter> X = {} \<and> z \<in> e" by auto
          have "v \<notin> e" 
          proof(rule ccontr)
            assume "\<not> v \<notin> e"
            then have "v \<in> e"  by auto
            then have "e = {z, v}" using `graph_invar E` `z \<noteq> v` 
              using \<open>e \<in> E \<and> e \<inter> X = {} \<and> z \<in> e\<close> by fastforce
            then have "e \<in> (graph_diff E X)"
              using \<open>e \<in> E \<and> e \<inter> X = {} \<and> z \<in> e\<close> graph_diff_def by auto
            then have "z \<in> connected_component (graph_diff E X) v"
              by (metis \<open>e = {z, v}\<close> in_con_comp_insert insert_Diff insert_commute)
            then have "z \<in> C" 
              by (simp add: comp_C)
            then show False 
              using \<open>z \<notin> C\<close> by auto
          qed
          then have "e\<in>E \<and>  e \<inter> (X\<inter>{v}) = {} \<and> z \<in> e" 
            using \<open>e \<in> E \<and> e \<inter> X = {} \<and> z \<in> e\<close> by blast
          then have "e \<in> graph_diff E (X\<union>{v})" unfolding graph_diff_def
            using \<open>e \<in> E \<and> e \<inter> X = {} \<and> z \<in> e\<close> \<open>v \<notin> e\<close> by blast
          then show "z\<in> Vs (graph_diff E (X \<union> {v}))" 
            using \<open>e \<in> E \<and> e \<inter> (X \<inter> {v}) = {} \<and> z \<in> e\<close> by blast
        qed
        have "\<forall>z \<in> C'. z \<in> connected_component (graph_diff E (X\<union>{v})) x"
        proof
          fix z
          assume "z\<in>C'"
          then have "(\<exists>p. walk_betw (graph_diff E X) x p z)" 
            by (metis in_connected_component_has_path odd_x)



          then obtain p where "walk_betw (graph_diff E X) x p z" by auto




          have "walk_betw (graph_diff E (X\<union>{v})) x p z"
          proof
            show "p \<noteq> []" 
              using \<open>walk_betw (graph_diff E X) x p z\<close> by auto
            show "hd p = x"
              using \<open>walk_betw (graph_diff E X) x p z\<close> by auto
            show "last p = z"
              using \<open>walk_betw (graph_diff E X) x p z\<close> by auto
            have "path (graph_diff E X) p" 
              by (meson \<open>walk_betw (graph_diff E X) x p z\<close> walk_betw_def)

            have "graph_invar (graph_diff E X)" 
              by (metis "1.prems"(2) \<open>X \<subseteq> Vs E \<and> barrier E X\<close> diff_is_union_elements finite_Un graph_diff_subset insert_Diff insert_subset)
            have "C' \<in> connected_components (graph_diff E X)" 
              by (simp add: \<open>C' \<in> odd_components (graph_diff E X)\<close> \<open>graph_invar (graph_diff E X)\<close> components_is_union_even_and_odd)
            have "hd p \<in> C'" 
              by (metis \<open>hd p = x\<close> in_own_connected_component odd_x)
            have "(component_edges (graph_diff E X) C') \<noteq> {}" 
              using \<open>e \<in> component_edges (graph_diff E X) C'\<close> by auto



            have "path (component_edges (graph_diff E X) C')  p" 

              by (simp add: \<open>C' \<in> connected_components (graph_diff E X)\<close> \<open>component_edges (graph_diff E X) C' \<noteq> {}\<close> \<open>graph_invar (graph_diff E X)\<close> \<open>hd p \<in> C'\<close> \<open>path (graph_diff E X) p\<close> defvd)

            have "(component_edges (graph_diff E X) C') = (component_edges (graph_diff E (X\<union>{v})) C')"
            proof(safe)
              { fix e
                assume "e \<in> component_edges (graph_diff E X) C'"
                then have "e \<subseteq> C'" unfolding component_edges_def
                  by blast
                then have "e \<in> (graph_diff E X)" using `e \<in> component_edges (graph_diff E X) C'`
                  using component_edges_subset by blast
                have "v \<notin> e" 
                  by (metis \<open>C' \<in> connected_components (graph_diff E X)\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>e \<subseteq> C'\<close> \<open>v \<in> C\<close> \<open>x \<notin> C\<close> connected_components_closed' connected_components_member_sym odd_x subsetD)
                then have "e \<inter> (X \<union> {v}) = {}" 
                  by (smt (verit) "1.prems"(2) DiffD2 Diff_insert_absorb UnE UnionI Vs_def \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>e \<in> graph_diff E X\<close> diff_disjoint_elements(2) disjoint_iff_not_equal)
                then have "e \<in> (graph_diff E (X\<union>{v}))" 
                  by (metis (mono_tags, lifting) \<open>e \<in> graph_diff E X\<close> graph_diff_def mem_Collect_eq)
                then show "e \<in> (component_edges (graph_diff E (X\<union>{v})) C')" 
                  unfolding component_edges_def 
                  using \<open>e \<in> graph_diff E X\<close> \<open>e \<subseteq> C'\<close> \<open>graph_invar (graph_diff E X)\<close> by fastforce
              }
              fix e
              assume "e \<in> (component_edges (graph_diff E (X\<union>{v})) C')"
              then have "e \<subseteq> C'" unfolding component_edges_def
                by blast
              then have "e \<in> (graph_diff E (X\<union>{v}))" 
                using \<open>e \<in> component_edges (graph_diff E (X \<union> {v})) C'\<close> component_edges_subset by blast

              then have "e \<inter> X = {}" unfolding graph_diff_def  
                by blast
              then have "e \<in> (graph_diff E X)" unfolding graph_diff_def 
                using \<open>e \<in> graph_diff E (X \<union> {v})\<close> graph_diff_subset by blast
              then show "e \<in> component_edges (graph_diff E X) C'" unfolding component_edges_def  
                using \<open>e \<subseteq> C'\<close> \<open>graph_invar (graph_diff E X)\<close> by fastforce
            qed

            then show "path (graph_diff E (X \<union> {v})) p"
              using `path (component_edges (graph_diff E X) C')  p` 
              by (metis component_edges_subset path_subset)

          qed

          then show "z \<in> connected_component (graph_diff E (X\<union>{v})) x" 
            by (simp add: has_path_in_connected_component)
        qed

        then have "C' \<subseteq> connected_component (graph_diff E (X\<union>{v})) x"
          by blast
        have "connected_component (graph_diff E (X \<union> {v})) x \<subseteq> C'"
        proof
          fix z
          assume "z \<in> connected_component (graph_diff E (X \<union> {v})) x"
          then have "\<exists>p. walk_betw (graph_diff E (X\<union>{v})) x p z" 
            by (meson \<open>\<forall>z\<in>C'. z \<in> Vs (graph_diff E (X \<union> {v}))\<close> \<open>e \<in> graph_diff E X \<and> x \<in> e\<close> \<open>e \<subseteq> C'\<close> in_connected_component_has_path subsetD)
          then obtain p where "walk_betw (graph_diff E (X\<union>{v})) x p z" by auto
          then have "path (graph_diff E (X\<union>{v})) p" 
            by (meson walk_betw_def)
          then have "path (graph_diff E X) p" 
            using \<open>graph_diff E (X \<union> {v}) \<subseteq> graph_diff E X\<close> path_subset by blast
          then have "walk_betw (graph_diff E X) x p z" 
            by (meson \<open>graph_diff E (X \<union> {v}) \<subseteq> graph_diff E X\<close> \<open>walk_betw (graph_diff E (X \<union> {v})) x p z\<close> walk_subset)
          then show "z \<in> C'" 
            using odd_x by blast
        qed
        then have "C' = connected_component (graph_diff E (X\<union>{v})) x" 
          using \<open>C' \<subseteq> connected_component (graph_diff E (X \<union> {v})) x\<close> by blast
        then show "C' \<in> odd_components (graph_diff E (X \<union> {v}))"
          unfolding odd_components_def
          using \<open>\<forall>z\<in>C'. z \<in> Vs (graph_diff E (X \<union> {v}))\<close> \<open>e \<in> graph_diff E X \<and> x \<in> e\<close> \<open>e \<subseteq> C'\<close> odd_x by fastforce
      qed
      then have "diff_odd_components E X \<subseteq> diff_odd_components E (X \<union> {v})"
        unfolding diff_odd_components_def
        using \<open>singleton_in_diff E X \<subseteq> singleton_in_diff E (X \<union> {v})\<close> by blast

      show False
      proof(cases "\<exists>x \<in> (C-{v}). x \<notin> Vs (graph_diff E (X \<union> {v}))")
        case True
        then  obtain x where "x \<in> (C-{v}) \<and> (x \<notin> Vs (graph_diff E (X \<union> {v})))" by auto
        then have "x \<in> Vs E"
          by (metis DiffD1 Diff_insert_absorb Vs_subset \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> connected_component_subset graph_diff_subset subset_Diff_insert)

        then have "x \<notin> X \<and> x \<notin> Vs (graph_diff E (X\<union>{v}))" 
          by (smt (verit, best) "1.prems"(2) DiffD1 \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>x \<in> C - {v} \<and> x \<notin> Vs (graph_diff E (X \<union> {v}))\<close> connected_component_subset diff_disjoint_elements(2) disjoint_iff_not_equal subset_iff)
        then have "{x} \<in> singleton_in_diff E (X \<union> {v})" unfolding singleton_in_diff_def

          using \<open>x \<in> C - {v} \<and> x \<notin> Vs (graph_diff E (X \<union> {v}))\<close> \<open>x \<in> Vs E\<close> by auto
        have "x \<in> Vs (graph_diff E X)" 
          by (metis DiffD1 Diff_insert_absorb \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>x \<in> C - {v} \<and> x \<notin> Vs (graph_diff E (X \<union> {v}))\<close> connected_component_subset subset_Diff_insert)
        then have "{x} \<notin> singleton_in_diff E (X)" unfolding singleton_in_diff_def 
          by blast
        have "{x} \<notin> odd_components (graph_diff E X)" unfolding odd_components_def 
          by (smt (verit, del_insts) Diff_insert_absorb \<open>v \<in> C\<close> \<open>x \<in> C - {v} \<and> x \<notin> Vs (graph_diff E (X \<union> {v}))\<close> comp_C connected_components_member_eq insert_iff mem_Collect_eq mk_disjoint_insert singletonI singleton_insert_inj_eq')
        then have "{x} \<notin> diff_odd_components E X"  unfolding diff_odd_components_def

          using \<open>{x} \<notin> singleton_in_diff E X\<close> by force

        then have "diff_odd_components E X \<subset> diff_odd_components E (X \<union> {v})" 
          unfolding diff_odd_components_def 
          by (metis UnCI \<open>diff_odd_components E X \<subseteq> diff_odd_components E (X \<union> {v})\<close> \<open>{x} \<in> singleton_in_diff E (X \<union> {v})\<close> diff_odd_components_def psubsetI)

        have "finite (connected_components (graph_diff E (X \<union> {v})))"

          by (meson "1.prems"(2) Vs_subset finite_con_comps finite_subset graph_diff_subset)
        have "  (odd_components (graph_diff E (X \<union> {v})))
          \<subseteq> connected_components (graph_diff E (X \<union> {v}))"
          unfolding odd_components_def 
          unfolding connected_components_def 
          by blast
        then have "finite  (odd_components (graph_diff E (X \<union> {v})))" 

          using \<open>finite (connected_components (graph_diff E (X \<union> {v})))\<close> finite_subset by blast

        have "finite ( singleton_in_diff E (X \<union> {v}))" 
          by (smt (verit) "1.prems"(2) Un_insert_right Vs_def Vs_subset \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> boolean_algebra_cancel.sup0 connected_component_subset diff_is_union_elements finite_Un finite_UnionD graph_diff_subset insert_Diff insert_subset)

        then have "finite (diff_odd_components E (X \<union> {v}))" 
          by (metis \<open>finite (odd_components (graph_diff E (X \<union> {v})))\<close> diff_odd_components_def finite_Un)
        then have "card (diff_odd_components E X) < card (diff_odd_components E (X \<union> {v}))"

          by (meson \<open>diff_odd_components E X \<subset> diff_odd_components E (X \<union> {v})\<close> psubset_card_mono)
        then have "card(X) + 1 \<le> card (diff_odd_components E (X \<union> {v}))" 
          by (simp add: \<open>card (diff_odd_components E X) = card X\<close>)
        have "card (X \<union> {v}) = (card X) + 1" 
          by (metis "1.prems"(2) IntI One_nat_def Un_insert_right \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> add.right_neutral add_Suc_right card.insert diff_disjoint_elements(2) empty_iff finite_subset in_connected_component_in_edges sup_bot_right)

        have "card (diff_odd_components E (X \<union> {v})) \<le> card (X \<union> {v})" using assms(2) unfolding tutte_condition_def

          by (metis "1.prems"(3) DiffD1 Un_insert_right \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>v \<in> C\<close> \<open>x \<in> C - {v} \<and> x \<notin> Vs (graph_diff E (X \<union> {v}))\<close> \<open>x \<in> Vs E\<close> boolean_algebra_cancel.sup0 comp_C connected_components_member_eq diff_connected_component_subset insert_Diff insert_subset tutte_condition_def)
        then have "card (diff_odd_components E (X \<union> {v})) \<le> (card X) + 1" 

          using \<open>card (X \<union> {v}) = card X + 1\<close> by presburger
        then have "barrier E (X \<union> {v})" 
          by (metis Un_empty \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>card (X \<union> {v}) = card X + 1\<close> \<open>card X + 1 \<le> card (diff_odd_components E (X \<union> {v}))\<close> barrier_def le_antisym)
        then have " (X \<union> {v}) \<in> ?B" 
          by (metis DiffD1 Un_insert_right \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> \<open>x \<in> C - {v} \<and> x \<notin> Vs (graph_diff E (X \<union> {v}))\<close> \<open>x \<in> Vs E\<close> connected_components_member_eq diff_connected_component_subset insert_subsetI mem_Collect_eq subsetD sup_bot_right)
        then show ?thesis 
          by (metis X_max \<open>card (diff_odd_components E X) < card (diff_odd_components E (X \<union> {v}))\<close> sup.strict_order_iff sup_ge1)
      next
        case False
        assume "\<not> (\<exists>x\<in>C - {v}. x \<notin> Vs (graph_diff E (X \<union> {v})))"
        then have "\<forall>x\<in>C - {v}. x \<in> Vs (graph_diff E (X \<union> {v}))" by auto


        have "\<exists> C' \<in> connected_components (graph_diff E (X \<union> {v})).C' \<subseteq> (C-{v}) \<and> odd (card C')"
        proof(rule ccontr)
          assume "\<not> (\<exists>C'\<in>connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> (C-{v}) \<and> odd (card C'))"
          then have "\<forall> C' \<in> connected_components (graph_diff E (X \<union> {v})).  \<not> C' \<subseteq> (C-{v}) \<or> even (card C')"
            by blast
          then have "\<forall> C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> (C-{v}) \<longrightarrow> (card C') \<noteq> 1"
            by fastforce
          then have "\<forall> C' \<in> connected_components (graph_diff E (X \<union> {v})).
     C' \<subseteq> (C-{v}) \<longrightarrow> (\<exists>x y. {x, y} \<subseteq> C')"
            by (metis connected_comp_nempty empty_subsetI equals0I insert_subset)

          have "\<forall> C' \<in> connected_components (graph_diff E (X \<union> {v})).
     C' \<subseteq> (C-{v}) \<longrightarrow> component_edges (graph_diff E (X \<union> {v})) C' \<noteq> {}"
          proof
            fix C'
            assume "C' \<in> connected_components (graph_diff E (X \<union> {v}))"
            show " C' \<subseteq> (C-{v}) \<longrightarrow> component_edges (graph_diff E (X \<union> {v})) C' \<noteq> {}"
            proof
              assume "C' \<subseteq> C - {v}"
              have "(card C') \<noteq> 1" 
                using \<open>C' \<in> connected_components (graph_diff E (X \<union> {v}))\<close> \<open>C' \<subseteq> C - {v}\<close> \<open>\<forall>C'\<in>connected_components (graph_diff E (X \<union> {v})). \<not> C' \<subseteq> C - {v} \<or> even (card C')\<close> by fastforce
              then have "(\<exists>x y. {x, y} \<subseteq> C' \<and> x \<noteq> y)" 
                by (metis (no_types, hide_lams) \<open>C' \<in> connected_components (graph_diff E (X \<union> {v}))\<close> \<open>\<forall>C'\<in>connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v} \<longrightarrow> (\<exists>x y. {x, y} \<subseteq> C')\<close> bot.extremum insert_subset insert_subsetI is_singletonI is_singleton_altdef order_class.order.eq_iff subsetI) 
              then obtain x y where "{x, y} \<subseteq> C' \<and> x \<noteq> y" by auto
              then have "y \<in> connected_component (graph_diff E (X \<union> {v})) x" 
                by (metis \<open>C' \<in> connected_components (graph_diff E (X \<union> {v}))\<close> connected_components_closed' insert_subset)
              then have "\<exists> p. walk_betw (graph_diff E (X \<union> {v})) x p y" 
                by (meson \<open>C' \<in> connected_components (graph_diff E (X \<union> {v}))\<close> \<open>{x, y} \<subseteq> C' \<and> x \<noteq> y\<close> connected_comp_verts_in_verts in_connected_component_has_path insert_subset)
              then obtain p where p_walk: "walk_betw (graph_diff E (X \<union> {v})) x p y" by auto
              then have "path (graph_diff E (X \<union> {v})) p"
                by (meson walk_betw_def)
              have "p \<noteq> []" using p_walk by auto

              have "hd p = x \<and> last p = y" using p_walk by auto
              then have "size p \<ge> 2" using  `{x, y} \<subseteq> C' \<and> x \<noteq> y` 
                by (metis One_nat_def Suc_1 Suc_leI \<open>p \<noteq> []\<close> antisym_conv1 append.simps(1) diff_add_inverse2 diff_less hd_Cons_tl last_snoc length_0_conv lessI less_Suc0 list.size(4) not_le)
              then have "{x, hd (tl p)} \<in> (graph_diff E (X \<union> {v}))" 
                by (metis One_nat_def Suc_1 Suc_pred \<open>hd p = x \<and> last p = y\<close> \<open>p \<noteq> []\<close> \<open>path (graph_diff E (X \<union> {v})) p\<close> hd_Cons_tl length_greater_0_conv length_tl lessI list.size(3) not_le path_2)
              have " hd (tl p) \<in> C'" 
                by (meson \<open>C' \<in> connected_components (graph_diff E (X \<union> {v}))\<close> \<open>{x, hd (tl p)} \<in> graph_diff E (X \<union> {v})\<close> \<open>{x, y} \<subseteq> C' \<and> x \<noteq> y\<close> edges_are_walks in_con_compI insert_subset)
              then have "{x, hd (tl p)} \<subseteq> C'" 
                using \<open>{x, y} \<subseteq> C' \<and> x \<noteq> y\<close> by blast
              then show " component_edges (graph_diff E (X \<union> {v})) C' \<noteq> {}" 
                by (smt (verit) \<open>{x, hd (tl p)} \<in> graph_diff E (X \<union> {v})\<close> component_edges_def empty_Collect_eq)
            qed
          qed

          have "(C-{v}) = \<Union>{C'. C' \<in> connected_components (graph_diff E (X \<union> {v})) \<and> C' \<subseteq> (C-{v})}"
          proof
            show "C - {v} \<subseteq> \<Union> {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}"
            proof
              fix x
              assume "x \<in> C - {v}"

              then have "connected_component (graph_diff E X) x = C" 
                by (metis DiffD1 comp_C connected_components_member_eq)




              then have "\<exists> C'. C' = connected_component (graph_diff E (X \<union> {v})) x"
                by blast
              then obtain C' where "C' = connected_component (graph_diff E (X \<union> {v})) x" by auto
              then have "C' \<subseteq> C - {v}"
                by (smt (verit, ccfv_SIG) "1.prems"(2) Diff_empty Un_insert_right Vs_subset \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>graph_diff E (X \<union> {v}) \<subseteq> graph_diff E X\<close> \<open>x \<in> C - {v}\<close> boolean_algebra_cancel.sup0 con_comp_subset connected_components_member_eq diff_disjoint_elements(2) disjoint_insert(2) graph_diff_subset in_connected_component_in_edges insert_subsetI subset_Diff_insert subset_iff)

              then have "C' \<in> connected_components (graph_diff E (X \<union> {v}))"
                unfolding connected_components_def
                using `C' = connected_component (graph_diff E (X \<union> {v})) x` 
                using False \<open>x \<in> C - {v}\<close> by fastforce

              then have "C' \<in> {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}"

                using \<open>C' \<subseteq> C - {v}\<close> by blast
              then  show "x \<in> \<Union> {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}"

                using UnionI \<open>C' = connected_component (graph_diff E (X \<union> {v})) x\<close> in_own_connected_component by fastforce
            qed

            show "\<Union> {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}} \<subseteq> C - {v}"

              by blast
          qed
          let ?A = "{C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}"
          have "finite ?A"

            by (metis (no_types, lifting) "1.prems"(2) Diff_empty Vs_subset \<open>C - {v} = \<Union> {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> connected_component_subset finite_Diff_insert finite_UnionD finite_subset graph_diff_subset)
          have "\<forall>C \<in> ?A. finite C" 
            by (metis (no_types, lifting) "1.prems"(2) Vs_subset connected_component_subs_Vs finite_subset graph_diff_subset mem_Collect_eq)
          have "\<forall>C1\<in>?A. \<forall>C2 \<in>?A. C1 \<noteq> C2 \<longrightarrow> C1 \<inter> C2 = {}" 
            by (metis (no_types, lifting) connected_components_disj mem_Collect_eq)
          then have "sum (\<lambda> C. card C) ?A = card (\<Union>C\<in>?A. C)" using union_card_is_sum[of ?A "(\<lambda> C. C)"]

            using \<open>\<forall>C\<in>{C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}. finite C\<close> \<open>finite {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}\<close> by blast
          then have "even (sum (\<lambda> C. card C) ?A)" 
            by (metis (no_types, lifting) \<open>\<not> (\<exists>C'\<in>connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v} \<and> odd (card C'))\<close> dvd_sum mem_Collect_eq)
          then have "even (card (C -{v}))" 
            using \<open>C - {v} = \<Union> {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}\<close> \<open>sum card {C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}} = card (\<Union>C\<in>{C' \<in> connected_components (graph_diff E (X \<union> {v})). C' \<subseteq> C - {v}}. C)\<close> by fastforce
          have "even (card C)" 
            using \<open>C \<in> even_components (graph_diff E X)\<close> even_components_def by fastforce

          have "odd (card (C -{v}))" using `even (card C)` 
            by (smt (verit, ccfv_threshold) "1.prems"(2) Diff_empty Diff_insert_absorb Diff_single_insert One_nat_def Vs_subset \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> card.empty card.insert card_Diff_subset card_gt_0_iff card_le_sym_Diff connected_component_subset double_diff dvd_diffD1 empty_iff empty_subsetI finite_Diff finite_subset graph_diff_subset insert_Diff nat_le_linear not_less odd_one)

          then show False 
            using \<open>even (card (C - {v}))\<close> by blast
        qed
        then obtain C' where "C'\<in>connected_components (graph_diff E (X \<union> {v})) \<and>
     C' \<subseteq> C - {v} \<and> odd (card C')" by auto

        then have "C' \<in> odd_components (graph_diff E (X \<union> {v}))" 
          unfolding odd_components_def  
          by (smt (z3) connected_comp_has_vert mem_Collect_eq)
        then have "C'  \<notin> odd_components (graph_diff E (X))" unfolding singleton_in_diff_def 

          by (smt (verit, ccfv_SIG) Diff_empty \<open>C' \<in> connected_components (graph_diff E (X \<union> {v})) \<and> C' \<subseteq> C - {v} \<and> odd (card C')\<close> comp_C connected_components_member_eq in_own_connected_component mem_Collect_eq odd_components_def subsetD subset_Diff_insert)
        have "C'  \<notin> singleton_in_diff E X" unfolding singleton_in_diff_def 

          by (smt (verit, ccfv_threshold) Vs_subset \<open>C' \<in> connected_components (graph_diff E (X \<union> {v})) \<and> C' \<subseteq> C - {v} \<and> odd (card C')\<close> \<open>graph_diff E (X \<union> {v}) \<subseteq> graph_diff E X\<close> connected_component_subs_Vs insert_subset mem_Collect_eq order_trans)
        then have "C' \<notin> diff_odd_components E X"  unfolding diff_odd_components_def

          using \<open>C' \<notin> odd_components (graph_diff E (X))\<close> by force

        then have "diff_odd_components E X \<subset> diff_odd_components E (X \<union> {v})" 
          unfolding diff_odd_components_def 
          by (metis UnCI \<open>C' \<in> odd_components (graph_diff E (X \<union> {v}))\<close> \<open>diff_odd_components E X \<subseteq> diff_odd_components E (X \<union> {v})\<close> diff_odd_components_def psubsetI)

        have "finite (connected_components (graph_diff E (X \<union> {v})))"

          by (meson "1.prems"(2) Vs_subset finite_con_comps finite_subset graph_diff_subset)
        have "  (odd_components (graph_diff E (X \<union> {v})))
          \<subseteq> connected_components (graph_diff E (X \<union> {v}))"
          unfolding odd_components_def 
          unfolding connected_components_def 
          by blast
        then have "finite  (odd_components (graph_diff E (X \<union> {v})))" 

          using \<open>finite (connected_components (graph_diff E (X \<union> {v})))\<close> finite_subset by blast

        have "finite ( singleton_in_diff E (X \<union> {v}))" 
          by (smt (verit) "1.prems"(2) Un_insert_right Vs_def Vs_subset \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> boolean_algebra_cancel.sup0 connected_component_subset diff_is_union_elements finite_Un finite_UnionD graph_diff_subset insert_Diff insert_subset)

        then have "finite (diff_odd_components E (X \<union> {v}))" 
          by (metis \<open>finite (odd_components (graph_diff E (X \<union> {v})))\<close> diff_odd_components_def finite_Un)
        then have "card (diff_odd_components E X) < card (diff_odd_components E (X \<union> {v}))"

          by (meson \<open>diff_odd_components E X \<subset> diff_odd_components E (X \<union> {v})\<close> psubset_card_mono)
        then have "card(X) + 1 \<le> card (diff_odd_components E (X \<union> {v}))" 
          by (simp add: \<open>card (diff_odd_components E X) = card X\<close>)
        have "card (X \<union> {v}) = (card X) + 1" 
          by (metis "1.prems"(2) IntI One_nat_def Un_insert_right \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> add.right_neutral add_Suc_right card.insert diff_disjoint_elements(2) empty_iff finite_subset in_connected_component_in_edges sup_bot_right)

        have "card (diff_odd_components E (X \<union> {v})) \<le> card (X \<union> {v})" using assms(2) unfolding tutte_condition_def

          by (smt (verit, ccfv_threshold) "1.prems"(2) "1.prems"(3) Un_insert_right Un_upper1 \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> boolean_algebra_cancel.sup0 connected_component_subset diff_is_union_elements insert_Diff insert_subset tutte_condition_def)
        then have "card (diff_odd_components E (X \<union> {v})) \<le> (card X) + 1" 

          using \<open>card (X \<union> {v}) = card X + 1\<close> by presburger
        then have "barrier E (X \<union> {v})" 
          by (metis Un_empty \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>card (X \<union> {v}) = card X + 1\<close> \<open>card X + 1 \<le> card (diff_odd_components E (X \<union> {v}))\<close> barrier_def le_antisym)
        then have " (X \<union> {v}) \<in> ?B" 
          by (metis Un_insert_right Vs_subset \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>\<exists>v\<in>Vs (graph_diff E X). connected_component (graph_diff E X) v = C\<close> \<open>v \<in> C\<close> connected_component_subset graph_diff_subset insert_subsetI mem_Collect_eq subsetD sup_bot_right)
        then show ?thesis 
          by (metis X_max \<open>card (diff_odd_components E X) < card (diff_odd_components E (X \<union> {v}))\<close> sup.strict_order_iff sup_ge1)
      qed
    qed

    have "\<forall>C \<in> (diff_odd_components E X). \<forall>v\<in>C. 
      \<exists>M. perfect_matching (graph_diff (component_edges E C) {v}) M" sorry


    have "\<forall>C \<in> (diff_odd_components E X). finite C"
      by (meson "1.prems"(2) component_in_E finite_subset)
    have "\<forall>C \<in> (diff_odd_components E X). C \<noteq> {} " 
      by (smt (verit, ccfv_threshold) UnE diff_odd_components_def disjoint_insert(2) inf_bot_right mem_Collect_eq odd_card_imp_not_empty odd_components_def singleton_in_diff_def)
    then have "\<forall>C \<in> (diff_odd_components E X). \<exists>c. c\<in>C" by auto

    then have "\<exists>Z. \<forall>C \<in> (diff_odd_components E X).\<exists>c \<in> Z. c\<in>C" 
      by (metis Collect_const mem_Collect_eq)
    then have "\<exists>Z. (\<forall>C \<in> (diff_odd_components E X).\<exists>c \<in> Z. c\<in>C) \<and> (\<forall>z \<in> Z. z \<in> Vs (diff_odd_components E X))" 
  by (metis vs_member_intro)
    then obtain Z where "(\<forall>C \<in> (diff_odd_components E X).\<exists>c \<in> Z. c\<in>C) \<and> (\<forall>z \<in> Z. z \<in> Vs (diff_odd_components E X))"     
      by meson
    
    then have "Z \<subseteq> Vs (diff_odd_components E X)" 
      by fastforce
    then have "\<forall>z \<in>Z. \<exists>C\<in> (diff_odd_components E X). z \<in> C" 
      by (meson \<open>(\<forall>C\<in>diff_odd_components E X. \<exists>c\<in>Z. c \<in> C) \<and> (\<forall>z\<in>Z. z \<in> Vs (diff_odd_components E X))\<close> vs_member_elim)
    have "\<forall>C\<in> (diff_odd_components E X). C \<subseteq> Vs E" 
      by (simp add: component_in_E)
    
    
    then have "Z \<subseteq> Vs E" 
      by (meson \<open>\<forall>z\<in>Z. \<exists>C\<in>diff_odd_components E X. z \<in> C\<close> subsetD subsetI)
    then have "finite Z" 
      using "1.prems"(2) finite_subset by auto

    have "\<exists>T\<subseteq>Z . \<forall>C\<in>(diff_odd_components E X).
       \<exists>b\<in>T. b \<in> C \<and> card (diff_odd_components E X) = card T"
      using yfsdf[of "(diff_odd_components E X)" Z] 
      by (smt (verit, best) "1.prems"(2) \<open>(\<forall>C\<in>diff_odd_components E X. \<exists>c\<in>Z. c \<in> C) \<and> (\<forall>z\<in>Z. z \<in> Vs (diff_odd_components E X))\<close> \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>finite Z\<close> barrier_def card_eq_0_iff diff_component_disjoint finite_subset)
    



    have "(\<forall>C \<in> (diff_odd_components E X).\<exists>c \<in> Z. c\<in>C)" 
      using \<open>(\<forall>C\<in>diff_odd_components E X. \<exists>c\<in>Z. c \<in> C) \<and> (\<forall>z\<in>Z. z \<in> Vs (diff_odd_components E X))\<close> by blast

    then have "card Z \<ge> card (diff_odd_components E X)"
      using  inj_cardinality[of "(diff_odd_components E X)" Z]
      by (metis (no_types, lifting) "1.prems"(2) \<open>X \<subseteq> Vs E \<and> barrier E X\<close> \<open>finite Z\<close> barrier_def card_eq_0_iff diff_component_disjoint finite_subset)
  
    then  have "\<exists>T \<subseteq> Z.  card T =  card (diff_odd_components E X)"
      by (meson obtain_subset_with_card_n)
    then obtain T where "T \<subseteq> Z \<and>  card T = card (diff_odd_components E X)" 


    
    then have "\<forall>C \<in> (diff_odd_components E X). card (C \<inter> Z) \<ge> 1" 
      by (metis One_nat_def Suc_leI \<open>\<forall>C\<in>diff_odd_components E X. \<exists>c\<in>Z. c \<in> C\<close> \<open>finite Z\<close> card_gt_0_iff disjoint_iff finite_Int)




    have "\<exists>T \<subseteq> Z. \<forall>C \<in> (diff_odd_components E X). card (C \<inter> T) = 1"
    proof(rule ccontr)
      assume "\<not> (\<exists>T\<subseteq>Z. \<forall>C\<in>diff_odd_components E X. card (C \<inter> T) = 1)"
      then have "\<forall>T\<subseteq>Z. \<exists>C\<in>diff_odd_components E X. card (C \<inter> T) \<noteq> 1"
        by meson
      then obtain T1 C1 where "T1 \<subseteq>Z \<and>  C1\<in>diff_odd_components E X \<and> card (C1 \<inter> T1) \<noteq> 1"
        
        by (meson Int_lower2)
      then have "card (C1 \<inter> T1) > 1" sledgehammer






    then have "\<exists>Z. \<forall>C \<in> (diff_odd_components E X). Z \<inter> C \<noteq> {}" 
      by (meson disjoint_iff)

    let ?Z = {a. a = 

    then have "\<exists>Z. \<forall>C \<in> (diff_odd_components E X).\<exists>c. Z \<inter> C = {c}"  
    obtain Z where "\<forall>C \<in> (diff_odd_components E X).\<exists>c.  Z\<inter>C = {c}" 










    then show False sledgehammer































end