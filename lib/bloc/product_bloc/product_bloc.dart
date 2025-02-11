import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hybrid_app/model/product_list.dart';
import 'package:hybrid_app/repository/product_repository.dart';
import 'package:hybrid_app/util/service_locator.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  //  5 product => limit = 5
  ProductBloc() : super(const ProductInitial(page: 0, limit: 5, skip: 0)) {
    on<ProductLoadEvent>(_loadProduct);
  }

  Future<void> _loadProduct(
    ProductLoadEvent event,
    Emitter<ProductState> emit,
  ) async {
    // only  if
    assert(state is ProductFinish || state is ProductInitial || state is ProductError);
    emit(Producting(limit: state.limit, page: state.page, skip: state.skip));
    final products = state is ProductFinish ? (state as ProductFinish).productList : ProductList(products: []);
    final productRepository = ServiceLocator.get<ProductRepository>();
    try {
      final newProducts = await productRepository.getAllProducts(
        skip: state.skip,
        page: state.page,
        limit: state.limit,
      );
      products.products!.addAll(newProducts.products!);
      emit(ProductFinish(
        limit: state.limit,
        page: state.page + 1,
        skip: state.skip,
        productList: products,
      ));
    } catch (e, s) {
      // visible to debug only : stack for knowing error
      debugPrint(s.toString());
      emit(ProductError(
        limit: state.limit,
        page: state.page,
        skip: state.skip,
        message: e.toString(),
      ));
    }
  }
}
