create or replace package body pkg_emp as 
PROCEDURE insert_emp(em_name varchar2, hredate date,
                                             man_id int, dep_id int, sal_uid number)  IS
    select_man_id employees.manager_id%type;
    sal_excp exception;
BEGIN
    IF man_id IS null and (sal_uid = 27 or sal_uid = 42) THEN
        INSERT INTO EMPLOYEES(emp_name, hiredate, manager_id, department_id, salary_uid)
        VALUES(em_name, hredate, man_id, dep_id, sal_uid);
    ELSE 
        raise sal_excp;
    END IF;
    SELECT MANAGER_ID INTO select_man_id FROM EMPLOYEES
    WHERE EMP_ID = man_id; 
    IF select_man_id IS NOT NULL
    THEN
        RAISE_APPLICATION_ERROR(-20002, 'manager id does not refer to a manager');
    ELSE
        INSERT INTO EMPLOYEES(emp_name, hiredate, manager_id, department_id, salary_uid)
        VALUES(em_name, hredate, man_id, dep_id, sal_uid);
    END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'manager id provided does not exist');
WHEN sal_excp THEN
    RAISE_APPLICATION_ERROR(-20018, 'Invalid Salary uid for the manager');
when others then
    dbms_output.put_line('An error occured! Please try again');
END;
procedure update_emp_name(v_emp_name in varchar2, v_emp_id in number) as
    begin
        update employees set emp_name = v_emp_name where emp_id = v_emp_id;
exception
    when others then
    dbms_output.put_line('An error occured! Please try again');
    end update_emp_name;
 procedure update_manager_id(v_manager_id in number, v_emp_id in number) as
    invalid_update exception;
    found boolean := false;
    n_emp_id employees.emp_id%type;
    n_manager_id employees.manager_id%type;
    begin
        select emp_id, manager_id into n_emp_id, n_manager_id from employees where emp_id = v_manager_id;
            if n_manager_id is null then
                update employees set manager_id = v_manager_id where emp_id = v_emp_id;
                found := true;
            end if;
        if not found then
            raise invalid_update;
        end if;
    exception
        when invalid_update then
            dbms_output.put_line('Manager with given id does not exist!');
    end update_manager_id;
procedure update_dept_id(v_dept_id in number, v_emp_id in number) as
    begin
        update employees set department_id = v_dept_id where emp_id = v_emp_id;
exception
    when others then
        dbms_output.put_line('An error occured! Please try again');
    end update_dept_id;
procedure update_salary_id(v_salary_id in number, v_emp_id in number) as
    begin
        update employees set salary_uid = v_salary_id where emp_id = v_emp_id;
    exception
        when others then
            dbms_output.put_line('An error occured! Please try again');
    end update_salary_id;
procedure delete_emp(v_emp_id in number) as
    begin
        delete from employees where emp_id = v_emp_id;
    -- exception
        -- when others then
        --     dbms_output.put_line('An error occured! Please try again');
    end delete_emp;
PROCEDURE insert_proj (v_manager_id number, proj_name varchar2)  IS
    select_man_id number;
BEGIN
    SELECT MANAGER_ID INTO select_man_id FROM EMPLOYEES
    WHERE EMP_ID = v_manager_id;
    IF select_man_id IS NOT NULL
    THEN
        RAISE_APPLICATION_ERROR(-20004, 'manager id does not refer to a manager');
    ELSE
        INSERT INTO PROJECTS(emp_id, proj_name)
        VALUES(v_manager_id, proj_name);
    END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'manager id provided does not exist');
END;
procedure update_proj_manager(v_manager_id in number, v_proj_id in number) as
    select_man_id number;
BEGIN
    SELECT MANAGER_ID INTO select_man_id FROM EMPLOYEES
    WHERE EMP_ID = v_manager_id;
    IF select_man_id IS NOT NULL
    THEN
        RAISE_APPLICATION_ERROR(-20004, 'manager id does not refer to a manager');
    ELSE
        UPDATE projects set emp_id = v_manager_id WHERE PROJ_ID = v_proj_id;
    END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003, 'manager id provided does not exist');
END update_proj_manager;
procedure delete_proj(v_proj_id in number) as
select_proj_id projects.proj_id%type;
begin
    select proj_id into select_proj_id from projects where proj_id = v_proj_id;
    delete from projects where proj_id = v_proj_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20005, 'project id provided does not exist');
when others then
    dbms_output.put_line('An error occured!');
end delete_proj;
procedure insert_sal(v_designation VARCHAR2,v_da FLOAT,v_hra FLOAT,v_basic NUMBER) as
final_sal float;
begin
    final_sal := v_da + v_hra + v_basic;
    insert into salary(da, hra, basic_pay, designation) values (v_da, v_hra, v_basic, v_designation);
    update salary set final_pay = final_sal where designation = v_designation;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end insert_sal;
procedure update_da(v_da in number, v_sal_id in number) as
old_da salary.da%type;
old_final_pay salary.final_pay%type;
new_final_pay salary.final_pay%type;
begin
    select da, final_pay into old_da, old_final_pay from salary where sal_uid = v_sal_id;
    update salary set da = v_da where sal_uid = v_sal_id;
    new_final_pay := old_final_pay - old_da + v_da;
    update salary set final_pay = new_final_pay where sal_uid = v_sal_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('Given salary id does not exist');
when others then
    dbms_output.put_line('An error occured!');
end update_da;
procedure update_hra(v_hra in number, v_sal_id in number) as
old_hra salary.hra%type;
old_final_pay salary.final_pay%type;
new_final_pay salary.final_pay%type;
begin
    select hra, final_pay into old_hra, old_final_pay from salary where sal_uid = v_sal_id;
    update salary set hra = v_hra where sal_uid = v_sal_id;
    new_final_pay := old_final_pay - old_hra + v_hra;
    update salary set final_pay = new_final_pay where sal_uid = v_sal_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('Given salary id does not exist');
when others then
    dbms_output.put_line('An error occured!');
end update_hra;
procedure update_basic_pay(v_basic_pay in number, v_sal_id in number) as
old_basic_pay salary.basic_pay%type;
old_final_pay salary.final_pay%type;
new_final_pay salary.final_pay%type;
begin
    select basic_pay, final_pay into old_basic_pay, old_final_pay from salary where sal_uid = v_sal_id;
    update salary set basic_pay = v_basic_pay where sal_uid = v_sal_id;
    new_final_pay := old_final_pay - old_basic_pay + v_basic_pay;
    update salary set final_pay = new_final_pay where sal_uid = v_sal_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('Given salary id does not exist');
when others then
    dbms_output.put_line('An error occured!');
end update_basic_pay;
procedure delete_sal(v_sal_id in number) as
begin
    delete from salary where sal_uid = v_sal_id;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end delete_sal;
procedure insert_dept(d_dept_name varchar2)
is
begin
insert into departments(dept_name)
values(d_dept_name);
end insert_dept;
procedure update_dept(d_name varchar2, d_dept_id number)
is begin
update departments 
set dept_name=d_name
where 
dept_id=d_dept_id;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end update_dept;
procedure delete_dept(d_id number)
is
begin
delete from departments where dept_id=d_id;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end delete_dept;

procedure insert_leave(v_emp_id in number , v_date in date, v_reason in varchar2) is
begin
    insert into leave values(v_emp_id, v_date, v_reason);
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end insert_leave;

procedure log_emp as
t_date date;
diff number;
begin
    select sysdate into t_date from dual;
    for rec in (select * from employees_log) loop
        diff := t_date - rec.log_date;
        if diff <= 5 then
            select * bulk collect into emp_log from employees_log where emp_id = rec.emp_id;
        end if;
    end loop;
    dbms_output.put_line('DML_TYPE' || ' | ' || 'OLD_EMP_NAME' || ' | ' || 'OLD_MANAGER_ID' || ' | ' || 'OLD_DEPT_ID' || ' | ' || 'OLD_SALARY_UID' || ' | '
                                || 'NEW_EMP_NAME' || ' | ' || 'NEW_MANAGER_ID' || ' | ' || 'NEW_DEPT_ID' || ' | ' || 'NEW_SALARY_UID' || ' | '|| 'EMP_ID' || ' | ' || 'LOG_DATE' || ' | ' || 'LOG_USER');
    for rec in (select * from employees_log) loop
        dbms_output.put_line(rec.DML_TYPE || ' | ' || rec.OLD_EMP_NAME || ' | ' || rec.OLD_MANAGER_ID || ' | ' || rec.OLD_DEPT_ID || ' | ' || rec.OLD_SALARY_UID || ' | '
                                || rec.NEW_EMP_NAME || ' | ' || rec.NEW_MANAGER_ID || ' | ' || rec.NEW_DEPT_ID || ' | ' || rec.NEW_SALARY_UID || ' | ' || rec.EMP_ID || ' | ' || rec.LOG_DATE || ' | ' || rec.LOG_USER);
    end loop;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end log_emp;
procedure log_proj as
t_date date;
diff number;
begin 
select sysdate into t_date from dual;
    for rec in (select * from projects_log) loop
        diff := t_date - rec.log_date;
        if diff <= 5 then
            select * bulk collect into proj_log from projects_log where log_date = rec.log_date;
        end if;
    end loop;
    dbms_output.put_line('DML_TYPE' || ' | ' || 'OLD_PROJ_ID' || ' | ' ||  'OLD_MANAGER_ID' || ' | ' ||  'OLD_PROJ_NAME' || ' | ' || 'NEW_PROJ_ID' || ' | ' ||  'NEW_MANAGER_ID' || ' | ' ||  'NEW_PROJ_NAME' || ' | ' || 'LOG_DATE' || ' | ' ||  'LOG_USER');
    for rec in (select * from projects_log) loop
        dbms_output.put_line(rec.DML_TYPE || ' | ' || rec.OLD_PROJ_ID || ' | ' ||  rec.OLD_MANAGER_ID || ' | ' ||  rec.OLD_PROJ_NAME || ' | ' || rec.NEW_PROJ_ID || ' | ' ||  rec.NEW_MANAGER_ID || ' | ' ||  rec.NEW_PROJ_NAME || ' | ' || rec.LOG_DATE || ' | ' ||  rec.LOG_USER);
    end loop;
end log_proj;
procedure log_sal as
t_date date;
diff number;
begin 
select sysdate into t_date from dual;
    for rec in (select * from salary_log) loop
        diff := t_date - rec.log_date;
        if diff <= 5 then
            select * bulk collect into sal_log from salary_log where log_date = rec.log_date;
        end if;
    end loop;
    dbms_output.put_line('LOG_USER' || ' | ' || 'LOG_DATE' || ' | ' || 'DML_TYPE' || ' | ' || 'OLD_DA' || ' | ' || 'NEW_DA' || ' | ' || 'OLD_HRA' || ' | ' || 'NEW_HRA' || ' | ' || 'OLD_BASIC_PAY' || ' | ' || 'NEW_BASIC_PAY' || ' | ' || 'OLD_FINAL' || ' | ' || 'NEW_FINAL' || ' | ' || 'OLD_DESIGNATION' || ' | ' || 'NEW_DESIGNATION' || ' | ' || 'SALARY_UID');
    -- for rec in (select * from sal_log) loop
    --     dbms_output.put_line(rec.LOG_USER || ' | ' || rec.LOG_DATE || ' | ' || rec.DML_TYPE || ' | ' || rec.OLD_DA || ' | ' || rec.NEW_DA || ' | ' || rec.OLD_HRA || ' | ' || rec.NEW_HRA || ' | ' || rec.OLD_BASIC_PAY || ' | ' || rec.NEW_BASIC_PAY || ' | ' || rec.OLD_FINAL || ' | ' || rec.NEW_FINAL || ' | ' || rec.OLD_DESIGNATION || ' | ' || rec.NEW_DESIGNATION || ' | ' || rec.SALARY_UID);
    -- end loop;
end log_sal;
procedure log_leave as
t_date date;
diff number;
begin 
    null;
end log_leave;
procedure log_dept as
t_date date;
diff number;
begin 
    for rec in (select * from dept_log) loop
        diff := t_date - rec.log_date;
        if diff <= 5 then
            select * bulk collect into department_log from dept_log where log_date = rec.log_date;
                    -- dbms_output.put_line(rec.log_user || ' | ' || rec.log_date || ' | ' || rec.dml_type || ' | ' || rec.old_dept_id || ' | ' || rec.new_dept_id || ' | ' || rec.old_dept_name || ' | ' || rec.new_dept_name);

        end if;
    end loop;
    -- dbms_output.put_line('log_user' || ' | ' || 'log_date' || ' | ' || 'dml_type' || ' | ' || 'old_dept_id' || ' | ' || 'new_dept_id' || ' | ' || 'old_dept_name' || ' | ' || 'new_dept_name');
    -- for rec in (select * from department_log) loop
    --     dbms_output.put_line(rec.log_user || ' | ' || rec.log_date || ' | ' || rec.dml_type || ' | ' || rec.old_dept_id || ' | ' || rec.new_dept_id || ' | ' || rec.old_dept_name || ' | ' || rec.new_dept_name);
    -- end loop;
end log_dept;   
function search_emp(v_emp_id in number) return boolean as
begin
    for rec in (select * from employees) loop
        if rec.emp_id = v_emp_id then
            return true;
        end if;
    end loop;
return false;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end search_emp;
function search_dept(d_dept_id in number) return boolean as
begin
    for rec in (select * from departments) loop
        if rec.dept_id = d_dept_id then
            return true;
        end if;
    end loop;
return false;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end search_dept;
function search_sal(v_sal_id in number) return boolean as
begin
    for rec in (select * from salary) loop
        if rec.sal_uid = v_sal_id then
            return true;
        end if;
    end loop;
return false;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end search_sal;
function search_proj(v_proj_id in number) return boolean as
begin
    for rec in (select * from projects) loop
        if rec.proj_id = v_proj_id then
            return true;
        end if;
    end loop;
return false;
EXCEPTION
when others then
    dbms_output.put_line('An error occured!');
end search_proj;
end pkg_emp;


-----------------------------------