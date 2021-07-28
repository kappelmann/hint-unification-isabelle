theory Examples
imports
  Hint_Unification
  Complex_Main
begin


ML\<open>
  open Utils
  val hint_unif = HO_Pat_Hint_Unif.h_unify;
  val gen_ctxt = Context.the_generic_context
\<close>

setup\<open>term_pat_setup\<close>
declare [[log_level=500]]


(* Simple Reflexive Tactic *)

datatype Expr = Var int | Op Expr Expr

fun eval :: "Expr \<Rightarrow> int" where
  "eval (Var i) = i"
| "eval (Op ex1 ex2) = (eval ex1) + (eval ex2)"

consts simpl :: "Expr \<Rightarrow> Expr"

lemma soundness :
  "P (eval (simpl x)) \<Longrightarrow> P (eval x)"
sorry


(*supply base case and inductive hint*)
lemma h_base [hints]:
  "x \<equiv> Var i \<Longrightarrow> eval x \<equiv> i"
by simp

lemma h_add [hints]:
  "x \<equiv> Op z1 z2 \<Longrightarrow> m \<equiv> eval z1 \<Longrightarrow> n \<equiv> eval z2 \<Longrightarrow> eval x \<equiv> m + n"
by simp


ML\<open>
  val t1 = @{term_pat "eval ?y"};
  val t2 = @{term_pat "a + (b + c) ::int"}\<close>

ML\<open>
  val (env,thm) = hint_unif (gen_ctxt ()) (t1,t2) (Envir.empty 0);
  trace_unif_result @{context} (t1,t2) (env,thm)\<close>


(* Advanced Reflexive Tactic *)
datatype AdvExpr =
  EUnit
 |EVar nat
 |EMult AdvExpr AdvExpr
 |EOpp AdvExpr

fun eval_adv :: "AdvExpr \<times> real list \<Rightarrow> real" where
  "eval_adv (EUnit,\<Gamma>) = 1"
 |"eval_adv (EVar i,\<Gamma>) = \<Gamma>!i"
 |"eval_adv (EMult ex1 ex2,\<Gamma>) = eval_adv (ex1,\<Gamma>) * eval_adv (ex2,\<Gamma>)"
 |"eval_adv (EOpp ex,\<Gamma>) = inverse (eval_adv (ex,\<Gamma>))"


(*hints for heap lookup*)
lemma h_var_base [hints]:
  "x \<equiv> EVar 0 \<Longrightarrow> \<Gamma> \<equiv> n#\<Theta> \<Longrightarrow> eval_adv (x,\<Gamma>) \<equiv> n"
by simp

lemma h_var_rec [hints]:
  "x \<equiv> EVar (Suc p) \<Longrightarrow> \<Gamma> \<equiv> s#\<Delta> \<Longrightarrow> n \<equiv> eval_adv (EVar p,\<Delta>) \<Longrightarrow> eval_adv (x,\<Gamma>) \<equiv> n"
by simp

(*hints for expressions*)
lemma h_unit [hints]:
  "x \<equiv> EUnit \<Longrightarrow> eval_adv (x,\<Gamma>) \<equiv> 1"
by simp
  
lemma h_times [hints]:
  "x \<equiv> EMult z1 z2 \<Longrightarrow> m \<equiv> eval_adv (z1,\<Gamma>) \<Longrightarrow> n \<equiv> eval_adv (z2,\<Gamma>) \<Longrightarrow> eval_adv (x,\<Gamma>) \<equiv> m * n"
by simp

lemma h_opp [hints]:
  "x \<equiv> EOpp z \<Longrightarrow> n \<equiv> eval_adv (z,\<Gamma>) \<Longrightarrow> eval_adv (x,\<Gamma>) \<equiv> inverse n"
by simp

ML\<open>
  val t1 = @{term_pat "eval_adv (?y,[1,3,5])"};
  val t2 = @{term_pat "3 * inverse 5 * 1::real"}\<close>

ML\<open>
  val (env,thm) = hint_unif (gen_ctxt ()) (t1,t2) (Envir.empty 0);
  trace_unif_result @{context} (t1,t2) (env,thm)\<close>


end